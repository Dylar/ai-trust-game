package service

import (
	"net/http"

	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
)

func SetupRoutes(
	mux *http.ServeMux,
	logger logging.Logger,
	healthHandler *HealthHandler,
	chatHandler *ChatHandler,
	startSessionHandler *StartSessionHandler,
	interactionHandler *InteractionHandler,
	clientLogHandler *ClientLogHandler,
	requestAnalysisHandler *RequestAnalysisHandler,
) {
	setupHealthRoute(mux, logger, healthHandler)
	setupChatRoute(mux, logger, chatHandler)
	setupStartSessionRoute(mux, logger, startSessionHandler)
	setupInteractionRoute(mux, logger, interactionHandler)
	setupClientLogRoute(mux, logger, clientLogHandler)
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

func setupClientLogRoute(mux *http.ServeMux, logger logging.Logger, clientLogHandler *ClientLogHandler) {
	handleClientLog := http.Handler(clientLogHandler)
	handleClientLog = logging.HttpLogging(logger)(handleClientLog)
	handleClientLog = network.RequestMiddleware(handleClientLog)
	handleClientLog = network.CORSMiddleware(handleClientLog)
	mux.Handle("/logs/client", handleClientLog)
}

func setupChatRoute(mux *http.ServeMux, logger logging.Logger, chatHandler *ChatHandler) {
	handleChat := http.Handler(chatHandler)
	handleChat = logging.HttpLogging(logger)(handleChat)
	handleChat = network.RequestMiddleware(handleChat)
	handleChat = network.CORSMiddleware(handleChat)
	mux.Handle("/chat", handleChat)
}

func setupStartSessionRoute(mux *http.ServeMux, logger logging.Logger, startSessionHandler *StartSessionHandler) {
	handleSessionStart := http.Handler(startSessionHandler)
	handleSessionStart = logging.HttpLogging(logger)(handleSessionStart)
	handleSessionStart = network.RequestMiddleware(handleSessionStart)
	handleSessionStart = network.CORSMiddleware(handleSessionStart)
	mux.Handle("/session/start", handleSessionStart)
}

func setupInteractionRoute(mux *http.ServeMux, logger logging.Logger, interactionHandler *InteractionHandler) {
	handleSessionStart := http.Handler(interactionHandler)
	handleSessionStart = logging.HttpLogging(logger)(handleSessionStart)
	handleSessionStart = network.RequestMiddleware(handleSessionStart)
	handleSessionStart = network.CORSMiddleware(handleSessionStart)
	mux.Handle("/interaction", handleSessionStart)
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
