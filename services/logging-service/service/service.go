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
	clientLogHandler *ClientLogHandler,
) {
	setupHealthRoute(mux, logger, healthHandler)
	setupClientLogRoute(mux, logger, clientLogHandler)
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
