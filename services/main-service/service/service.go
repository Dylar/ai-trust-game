package service

import (
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"net/http"
)

func RegisterRoutes(mux *http.ServeMux) {
	chatHandler := NewChatHandler()
	mux.Handle("/chat", logging.HttpLogging(chatHandler))

	mux.HandleFunc("/health", handleHealth)
}
