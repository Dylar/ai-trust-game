package service

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"github.com/Dylar/ai-trust-game/pkg/audit"
	"github.com/Dylar/ai-trust-game/pkg/network"
)

var ErrNoAnalysisRequestID = errors.New("no analysis request id provided")
var ErrNoAnalysisSessionID = errors.New("no analysis session id provided")
var ErrRequestAnalysisNotFound = errors.New("request analysis not found")
var ErrSessionAnalysisNotFound = errors.New("session analysis not found")

type requestAnalysisRepository interface {
	Get(requestID string) (audit.RequestAnalysis, bool)
	ListBySession(sessionID string) []audit.RequestAnalysis
}

type RequestAnalysisHandler struct {
	repo       requestAnalysisRepository
	summarizer audit.IntentSummarizer
}

func NewRequestAnalysisHandler(repo requestAnalysisRepository) *RequestAnalysisHandler {
	return NewRequestAnalysisHandlerWithSummarizer(repo, audit.NoopIntentSummarizer{})
}

func NewRequestAnalysisHandlerWithSummarizer(
	repo requestAnalysisRepository,
	summarizer audit.IntentSummarizer,
) *RequestAnalysisHandler {
	if summarizer == nil {
		summarizer = audit.NoopIntentSummarizer{}
	}
	return &RequestAnalysisHandler{repo: repo, summarizer: summarizer}
}

func (handler *RequestAnalysisHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodGet {
		network.WriteJSON(w, http.StatusMethodNotAllowed, nil)
		return
	}

	path := req.URL.Path
	if strings.HasPrefix(path, "/analysis/session/") {
		response, err := handler.handleGetSessionAnalysis(sessionIDFromPath(path))
		if err != nil {
			status, body := handler.mapSessionAnalysisError(err)
			network.WriteJSON(w, status, body)
			return
		}

		network.WriteJSON(w, http.StatusOK, response)
		return
	}

	response, err := handler.handleGetRequestAnalysis(requestIDFromPath(path))
	if err != nil {
		status, body := handler.mapRequestAnalysisError(err)
		network.WriteJSON(w, status, body)
		return
	}

	network.WriteJSON(w, http.StatusOK, response)
}

func (handler *RequestAnalysisHandler) handleGetRequestAnalysis(requestID string) (RequestAnalysisResponse, error) {
	requestID = strings.TrimSpace(requestID)
	if requestID == "" {
		return RequestAnalysisResponse{}, ErrNoAnalysisRequestID
	}

	analysis, ok := handler.repo.Get(requestID)
	if !ok {
		return RequestAnalysisResponse{}, ErrRequestAnalysisNotFound
	}

	return RequestAnalysisResponse{
		RequestID:      analysis.RequestID,
		SessionID:      analysis.SessionID,
		CompletedAt:    analysis.CompletedAt,
		Classification: string(analysis.Classification),
		Signals:        analysis.Signals,
		AttackPatterns: analysis.AttackPatterns,
		IntentSummary:  analysis.IntentSummary,
		EventCount:     analysis.EventCount,
		SuspicionCount: analysis.SuspicionCount,
		ModelFailCount: analysis.ModelFailCount,
	}, nil
}

func (handler *RequestAnalysisHandler) mapRequestAnalysisError(err error) (int, RequestAnalysisResponse) {
	if errors.Is(err, ErrNoAnalysisRequestID) {
		return http.StatusBadRequest, RequestAnalysisResponse{}
	}
	if errors.Is(err, ErrRequestAnalysisNotFound) {
		return http.StatusNotFound, RequestAnalysisResponse{}
	}

	return http.StatusInternalServerError, RequestAnalysisResponse{}
}

func (handler *RequestAnalysisHandler) handleGetSessionAnalysis(sessionID string) (SessionAnalysisResponse, error) {
	sessionID = strings.TrimSpace(sessionID)
	if sessionID == "" {
		return SessionAnalysisResponse{}, ErrNoAnalysisSessionID
	}

	analyses := handler.repo.ListBySession(sessionID)
	if len(analyses) == 0 {
		return SessionAnalysisResponse{}, ErrSessionAnalysisNotFound
	}

	session := audit.AnalyzeSession(analyses)
	response := SessionAnalysisResponse{
		SessionID:      sessionID,
		Classification: string(session.Classification),
		Signals:        session.Signals,
		AttackPatterns: session.AttackPatterns,
		RequestCount:   session.RequestCount,
		SuspicionCount: session.SuspicionCount,
		ModelFailCount: session.ModelFailCount,
		Requests:       make([]RequestAnalysisResponse, 0, len(analyses)),
	}

	if handler.shouldSummarizeSessionIntent(session) {
		summary, err := handler.summarizer.SummarizeSession(context.Background(), session)
		if err == nil {
			response.IntentSummary = summary
		}
	}

	for _, analysis := range analyses {
		response.Requests = append(response.Requests, RequestAnalysisResponse{
			RequestID:      analysis.RequestID,
			SessionID:      analysis.SessionID,
			CompletedAt:    analysis.CompletedAt,
			Classification: string(analysis.Classification),
			Signals:        analysis.Signals,
			AttackPatterns: analysis.AttackPatterns,
			IntentSummary:  analysis.IntentSummary,
			EventCount:     analysis.EventCount,
			SuspicionCount: analysis.SuspicionCount,
			ModelFailCount: analysis.ModelFailCount,
		})
	}

	return response, nil
}

func (handler *RequestAnalysisHandler) shouldSummarizeSessionIntent(session audit.SessionAnalysis) bool {
	return session.RequestCount > 1 || session.Classification != audit.ClassificationClean
}

func (handler *RequestAnalysisHandler) mapSessionAnalysisError(err error) (int, SessionAnalysisResponse) {
	if errors.Is(err, ErrNoAnalysisSessionID) {
		return http.StatusBadRequest, SessionAnalysisResponse{}
	}
	if errors.Is(err, ErrSessionAnalysisNotFound) {
		return http.StatusNotFound, SessionAnalysisResponse{}
	}

	return http.StatusInternalServerError, SessionAnalysisResponse{}
}

func requestIDFromPath(path string) string {
	const prefix = "/analysis/request/"
	if !strings.HasPrefix(path, prefix) {
		return ""
	}

	return strings.TrimPrefix(path, prefix)
}

func sessionIDFromPath(path string) string {
	const prefix = "/analysis/session/"
	if !strings.HasPrefix(path, prefix) {
		return ""
	}

	return strings.TrimPrefix(path, prefix)
}
