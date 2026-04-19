package service

import (
	"errors"
	"net/http"
	"strings"

	"github.com/Dylar/ai-trust-game/pkg/audit"
	"github.com/Dylar/ai-trust-game/pkg/network"
)

var ErrNoAnalysisRequestID = errors.New("no analysis request id provided")
var ErrRequestAnalysisNotFound = errors.New("request analysis not found")

type requestAnalysisRepository interface {
	Get(requestID string) (audit.RequestAnalysis, bool)
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

	response, err := handler.handleGetRequestAnalysis(requestIDFromPath(req.URL.Path))
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

func requestIDFromPath(path string) string {
	const prefix = "/analysis/request/"
	if !strings.HasPrefix(path, prefix) {
		return ""
	}

	return strings.TrimPrefix(path, prefix)
}
