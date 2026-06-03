package service

import (
	"net/http"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
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
	handleHealth := http.Handler(healthHandler)
	handleHealth = logging.HttpLogging(logger)(handleHealth)
	handleHealth = network.RequestMiddleware(handleHealth)
	handleHealth = network.CORSMiddleware(handleHealth)
	mux.Handle("/healthz", handleHealth)
}

func setupEventRoute(mux *http.ServeMux, logger logging.Logger, eventHandler *EventHandler) {
	handleEvent := http.Handler(eventHandler)
	handleEvent = logging.HttpLogging(logger)(handleEvent)
	handleEvent = network.RequestMiddleware(handleEvent)
	handleEvent = network.CORSMiddleware(handleEvent)
	mux.Handle("/audit/events", handleEvent)
}

func setupRequestAnalysisRoute(mux *http.ServeMux, logger logging.Logger, requestAnalysisHandler *RequestAnalysisHandler) {
	handleRequestAnalysis := http.Handler(requestAnalysisHandler)
	handleRequestAnalysis = logging.HttpLogging(logger)(handleRequestAnalysis)
	handleRequestAnalysis = network.RequestMiddleware(handleRequestAnalysis)
	handleRequestAnalysis = network.CORSMiddleware(handleRequestAnalysis)
	mux.Handle("/analysis/request/", handleRequestAnalysis)
}

func setupSessionAnalysisRoute(mux *http.ServeMux, logger logging.Logger, requestAnalysisHandler *RequestAnalysisHandler) {
	handleSessionAnalysis := http.Handler(requestAnalysisHandler)
	handleSessionAnalysis = logging.HttpLogging(logger)(handleSessionAnalysis)
	handleSessionAnalysis = network.RequestMiddleware(handleSessionAnalysis)
	handleSessionAnalysis = network.CORSMiddleware(handleSessionAnalysis)
	mux.Handle("/analysis/session/", handleSessionAnalysis)
}
