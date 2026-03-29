package service

import (
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"net/http"
)

func SetupRoutes(mux *http.ServeMux, logger logging.Logger, chatHandler *ChatHandler) {
	chat := http.Handler(chatHandler)
	chat = logging.HttpLogging(logger)(chat)
	chat = network.RequestIDMiddleware(chat)

	mux.Handle("/chat", chat)
	mux.HandleFunc("/health", handleHealth)
}
