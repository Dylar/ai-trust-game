package audit

import (
	"strings"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/llm"
	"sort"
	"time"
)

type Classification string

const (
	ClassificationClean           Classification = "clean"
	ClassificationSuspicious      Classification = "suspicious"
	ClassificationFailedModelStep Classification = "failed_model_step"
)

const (
	AttackPatternRoleEscalation     = "role_escalation_attempt"
	AttackPatternSecretExfiltration = "secret_exfiltration_attempt"
	AttackPatternPromptInjection    = "prompt_injection_attempt"
	AttackPatternPasswordGuessing   = "password_guessing_attempt"
	AttackPatternCapabilityRecon    = "capability_recon_attempt"
)

type RequestAnalysis struct {
	RequestID      string
	SessionID      string
	StartedAt      time.Time
	CompletedAt    time.Time
	Classification Classification
	Signals        []string
	AttackPatterns []string
	EventCount     int
	SuspicionCount int
	ModelFailCount int
}

type SessionAnalysis struct {
	SessionID      string
	Classification Classification
	Signals        []string
	AttackPatterns []string
	RequestCount   int
	SuspicionCount int
	ModelFailCount int
	Requests       []RequestAnalysis
}

func AnalyzeRequest(events []Event) RequestAnalysis {
	analysis := RequestAnalysis{
		Classification: ClassificationClean,
		EventCount:     len(events),
	}

	signals := map[string]struct{}{}
	attackPatterns := map[string]struct{}{}

	for _, event := range events {
		if analysis.RequestID == "" && event.RequestID != "" {
			analysis.RequestID = event.RequestID
		}
		if analysis.SessionID == "" && event.SessionID != "" {
			analysis.SessionID = event.SessionID
		}
		if analysis.StartedAt.IsZero() || event.Timestamp.Before(analysis.StartedAt) {
			analysis.StartedAt = event.Timestamp
		}
		if analysis.CompletedAt.IsZero() || event.Timestamp.After(analysis.CompletedAt) {
			analysis.CompletedAt = event.Timestamp
		}

		if event.Suspicion != "" {
			analysis.SuspicionCount++
			signals[event.Suspicion] = struct{}{}
			if analysis.Classification == ClassificationClean {
				analysis.Classification = ClassificationSuspicious
			}
		}

		if isModelStepFailure(event) {
			analysis.ModelFailCount++
			if event.Failure != "" {
				signals[string(event.Failure)] = struct{}{}
			}
			analysis.Classification = ClassificationFailedModelStep
		}

		collectAttackPatterns(attackPatterns, event)
	}

	analysis.Signals = sortedSignals(signals)
	analysis.AttackPatterns = sortedSignals(attackPatterns)
	return analysis
}

func AnalyzeRequests(events []Event) []RequestAnalysis {
	grouped := map[string][]Event{}
	var order []string

	for _, event := range events {
		requestID := event.RequestID
		if _, ok := grouped[requestID]; !ok {
			order = append(order, requestID)
		}
		grouped[requestID] = append(grouped[requestID], event)
	}

	analyses := make([]RequestAnalysis, 0, len(order))
	for _, requestID := range order {
		analyses = append(analyses, AnalyzeRequest(grouped[requestID]))
	}

	return analyses
}

func AnalyzeSession(analyses []RequestAnalysis) SessionAnalysis {
	session := SessionAnalysis{
		Classification: ClassificationClean,
		RequestCount:   len(analyses),
		Requests:       analyses,
	}
	signals := map[string]struct{}{}
	attackPatterns := map[string]struct{}{}

	for _, analysis := range analyses {
		if session.SessionID == "" && analysis.SessionID != "" {
			session.SessionID = analysis.SessionID
		}

		session.SuspicionCount += analysis.SuspicionCount
		session.ModelFailCount += analysis.ModelFailCount
		for _, signal := range analysis.Signals {
			signals[signal] = struct{}{}
		}
		for _, attackPattern := range analysis.AttackPatterns {
			attackPatterns[attackPattern] = struct{}{}
		}

		switch analysis.Classification {
		case ClassificationFailedModelStep:
			session.Classification = ClassificationFailedModelStep
		case ClassificationSuspicious:
			if session.Classification == ClassificationClean {
				session.Classification = ClassificationSuspicious
			}
		}
	}

	session.Signals = sortedSignals(signals)
	session.AttackPatterns = sortedSignals(attackPatterns)
	return session
}

func collectAttackPatterns(patterns map[string]struct{}, event Event) {
	if event.Suspicion == SuspicionClaimedRoleExceedsTrusted {
		patterns[AttackPatternRoleEscalation] = struct{}{}
	}
	if event.Suspicion == SuspicionPossiblePromptInjection || containsPromptInjectionPhrase(event.Input) {
		patterns[AttackPatternPromptInjection] = struct{}{}
	}

	switch event.Action {
	case domain.ActionReadSecret:
		patterns[AttackPatternSecretExfiltration] = struct{}{}
	case domain.ActionSubmitAdminPassword:
		patterns[AttackPatternPasswordGuessing] = struct{}{}
	case domain.ActionListAvailableActions:
		patterns[AttackPatternCapabilityRecon] = struct{}{}
	}
}

func containsPromptInjectionPhrase(input string) bool {
	lower := strings.ToLower(strings.TrimSpace(input))
	if lower == "" {
		return false
	}

	return strings.Contains(lower, "ignore previous instructions")
}

func isModelStepFailure(event Event) bool {
	if event.Outcome != OutcomeFailed {
		return false
	}

	return event.Stage == string(llm.StagePlanner) || event.Stage == string(llm.StageResponseBuilder)
}

func sortedSignals(signals map[string]struct{}) []string {
	items := make([]string, 0, len(signals))
	for signal := range signals {
		items = append(items, signal)
	}
	sort.Strings(items)
	return items
}
