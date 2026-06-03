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
	chatHandler *ChatHandler,
	startSessionHandler *StartSessionHandler,
	interactionHandler *InteractionHandler,
) {
	setupHealthRoute(mux, logger, healthHandler)
	setupChatRoute(mux, logger, chatHandler)
	setupStartSessionRoute(mux, logger, startSessionHandler)
	setupInteractionRoute(mux, logger, interactionHandler)
}

func setupHealthRoute(mux *http.ServeMux, logger logging.Logger, healthHandler *HealthHandler) {
	handleHealth := http.Handler(healthHandler)
	handleHealth = logging.HttpLogging(logger)(handleHealth)
	handleHealth = network.RequestMiddleware(handleHealth)
	handleHealth = network.CORSMiddleware(handleHealth)
	mux.Handle("/healthz", handleHealth)
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
