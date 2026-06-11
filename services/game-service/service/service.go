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
	chatHandler *ChatHandler,
	startSessionHandler *StartSessionHandler,
	sessionQueryHandler *SessionQueryHandler,
	interactionHandler *InteractionHandler,
) {
	setupHealthRoute(mux, logger, healthHandler)
	setupChatRoute(mux, logger, chatHandler)
	setupStartSessionRoute(mux, logger, startSessionHandler)
	setupSessionQueryRoute(mux, logger, sessionQueryHandler)
	setupInteractionRoute(mux, logger, interactionHandler)
}

func setupHealthRoute(mux *http.ServeMux, logger logging.Logger, healthHandler *HealthHandler) {
	handleHealth := infra.StandardHTTPHandler(logger, healthHandler)
	mux.Handle("/healthz", handleHealth)
}

func setupChatRoute(mux *http.ServeMux, logger logging.Logger, chatHandler *ChatHandler) {
	handleChat := infra.StandardHTTPHandler(logger, chatHandler)
	mux.Handle("/chat", handleChat)
}

func setupStartSessionRoute(mux *http.ServeMux, logger logging.Logger, startSessionHandler *StartSessionHandler) {
	handleSessionStart := infra.StandardHTTPHandler(logger, startSessionHandler)
	mux.Handle("/session/start", handleSessionStart)
}

func setupSessionQueryRoute(mux *http.ServeMux, logger logging.Logger, sessionQueryHandler *SessionQueryHandler) {
	handleSessionQuery := infra.StandardHTTPHandler(logger, sessionQueryHandler)
	mux.Handle("/session/", handleSessionQuery)
}

func setupInteractionRoute(mux *http.ServeMux, logger logging.Logger, interactionHandler *InteractionHandler) {
	handleInteraction := infra.StandardHTTPHandler(logger, interactionHandler)
	mux.Handle("/interaction", handleInteraction)
}
