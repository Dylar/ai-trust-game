package service

import (
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
	repo requestAnalysisRepository
}

func NewRequestAnalysisHandler(repo requestAnalysisRepository) *RequestAnalysisHandler {
	return &RequestAnalysisHandler{repo: repo}
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
		Classification: string(analysis.Classification),
		Signals:        analysis.Signals,
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

	response := SessionAnalysisResponse{
		SessionID:    sessionID,
		RequestCount: len(analyses),
		Requests:     make([]RequestAnalysisResponse, 0, len(analyses)),
	}

	for _, analysis := range analyses {
		response.Requests = append(response.Requests, RequestAnalysisResponse{
			RequestID:      analysis.RequestID,
			SessionID:      analysis.SessionID,
			Classification: string(analysis.Classification),
			Signals:        analysis.Signals,
			EventCount:     analysis.EventCount,
			SuspicionCount: analysis.SuspicionCount,
			ModelFailCount: analysis.ModelFailCount,
		})
		response.SuspicionCount += analysis.SuspicionCount
		response.ModelFailCount += analysis.ModelFailCount
	}

	return response, nil
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
