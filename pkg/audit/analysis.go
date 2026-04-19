package audit

import (
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

type RequestAnalysis struct {
	RequestID      string
	SessionID      string
	StartedAt      time.Time
	CompletedAt    time.Time
	Classification Classification
	Signals        []string
	EventCount     int
	SuspicionCount int
	ModelFailCount int
}

type SessionAnalysis struct {
	SessionID      string
	Classification Classification
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
	}

	analysis.Signals = sortedSignals(signals)
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

	for _, analysis := range analyses {
		if session.SessionID == "" && analysis.SessionID != "" {
			session.SessionID = analysis.SessionID
		}

		session.SuspicionCount += analysis.SuspicionCount
		session.ModelFailCount += analysis.ModelFailCount

		switch analysis.Classification {
		case ClassificationFailedModelStep:
			session.Classification = ClassificationFailedModelStep
		case ClassificationSuspicious:
			if session.Classification == ClassificationClean {
				session.Classification = ClassificationSuspicious
			}
		}
	}

	return session
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
