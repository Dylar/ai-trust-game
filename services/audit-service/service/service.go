package service

import (
	"net/http"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/infra"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
)

func SetupRoutes(
	mux *http.ServeMux,
	logger logging.Logger,
	healthHandler *HealthHandler,
	eventHandler *EventHandler,
	requestAnalysisHandler *RequestAnalysisHandler,
) {
	setupHealthRoute(mux, logger, healthHandler)
	setupEventRoute(mux, logger, eventHandler)
	setupRequestAnalysisRoute(mux, logger, requestAnalysisHandler)
	setupSessionAnalysisRoute(mux, logger, requestAnalysisHandler)
}

func setupHealthRoute(mux *http.ServeMux, logger logging.Logger, healthHandler *HealthHandler) {
	handleHealth := infra.StandardHTTPHandler(logger, healthHandler)
	mux.Handle("/healthz", handleHealth)
}

func setupEventRoute(mux *http.ServeMux, logger logging.Logger, eventHandler *EventHandler) {
	handleEvent := infra.StandardHTTPHandler(logger, eventHandler)
	mux.Handle("/audit/events", handleEvent)
}

func setupRequestAnalysisRoute(mux *http.ServeMux, logger logging.Logger, requestAnalysisHandler *RequestAnalysisHandler) {
	handleRequestAnalysis := infra.StandardHTTPHandler(logger, requestAnalysisHandler)
	mux.Handle("/analysis/request/", handleRequestAnalysis)
}

func setupSessionAnalysisRoute(mux *http.ServeMux, logger logging.Logger, requestAnalysisHandler *RequestAnalysisHandler) {
	handleSessionAnalysis := infra.StandardHTTPHandler(logger, requestAnalysisHandler)
	mux.Handle("/analysis/session/", handleSessionAnalysis)
}
