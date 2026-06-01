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
	proxyHandler *ProxyHandler,
) {
	setupHealthRoute(mux, logger, healthHandler)
	setupProxyRoutes(mux, logger, proxyHandler)
}

func setupHealthRoute(mux *http.ServeMux, logger logging.Logger, healthHandler *HealthHandler) {
	handleHealth := http.Handler(healthHandler)
	handleHealth = logging.HttpLogging(logger)(handleHealth)
	handleHealth = network.RequestMiddleware(handleHealth)
	handleHealth = network.CORSMiddleware(handleHealth)
	mux.Handle("/healthz", handleHealth)
}

func setupProxyRoutes(mux *http.ServeMux, logger logging.Logger, proxyHandler *ProxyHandler) {
	handleProxy := http.Handler(proxyHandler)
	handleProxy = logging.HttpLogging(logger)(handleProxy)
	handleProxy = network.RequestMiddleware(handleProxy)
	handleProxy = network.CORSMiddleware(handleProxy)

	mux.Handle("/analysis/", handleProxy)
	mux.Handle("/chat", handleProxy)
	mux.Handle("/interaction", handleProxy)
	mux.Handle("/logs/", handleProxy)
	mux.Handle("/session/", handleProxy)
}
