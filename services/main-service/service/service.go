package service

import (
	"net/http"

	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
)

func SetupRoutes(
	mux *http.ServeMux,
	logger logging.Logger,
	chatHandler *ChatHandler,
	startSessionHandler *StartSessionHandler,
	interactionHandler *InteractionHandler,
) {
	setupChatRoute(mux, logger, chatHandler)
	setupStartSessionRoute(mux, logger, startSessionHandler)
	setupInteractionRoute(mux, logger, interactionHandler)

	mux.HandleFunc("/health", handleHealth)
}

func setupChatRoute(mux *http.ServeMux, logger logging.Logger, chatHandler *ChatHandler) {
	handleChat := http.Handler(chatHandler)
	handleChat = logging.HttpLogging(logger)(handleChat)
	handleChat = network.RequestMiddleware(handleChat)
	mux.Handle("/chat", handleChat)
}

func setupStartSessionRoute(mux *http.ServeMux, logger logging.Logger, startSessionHandler *StartSessionHandler) {
	handleSessionStart := http.Handler(startSessionHandler)
	handleSessionStart = logging.HttpLogging(logger)(handleSessionStart)
	handleSessionStart = network.RequestMiddleware(handleSessionStart)
	mux.Handle("/session/start", handleSessionStart)
}

func setupInteractionRoute(mux *http.ServeMux, logger logging.Logger, interactionHandler *InteractionHandler) {
	handleSessionStart := http.Handler(interactionHandler)
	handleSessionStart = logging.HttpLogging(logger)(handleSessionStart)
	handleSessionStart = network.RequestMiddleware(handleSessionStart)
	mux.Handle("/interaction", handleSessionStart)
}
