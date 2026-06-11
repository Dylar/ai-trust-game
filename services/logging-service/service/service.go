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
	clientLogHandler *ClientLogHandler,
) {
	setupHealthRoute(mux, logger, healthHandler)
	setupClientLogRoute(mux, logger, clientLogHandler)
}

func setupHealthRoute(mux *http.ServeMux, logger logging.Logger, healthHandler *HealthHandler) {
	handleHealth := infra.StandardHTTPHandler(logger, healthHandler)
	mux.Handle("/healthz", handleHealth)
}

func setupClientLogRoute(mux *http.ServeMux, logger logging.Logger, clientLogHandler *ClientLogHandler) {
	handleClientLog := infra.StandardHTTPHandler(logger, clientLogHandler)
	mux.Handle("/logs/client", handleClientLog)
}
