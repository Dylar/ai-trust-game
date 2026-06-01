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
	gameProxyHandler *ProxyHandler,
	loggingProxyHandler *ProxyHandler,
) {
	setupHealthRoute(mux, logger, healthHandler)
	setupProxyRoutes(mux, logger, gameProxyHandler, loggingProxyHandler)
}

func setupHealthRoute(mux *http.ServeMux, logger logging.Logger, healthHandler *HealthHandler) {
	handleHealth := http.Handler(healthHandler)
	handleHealth = logging.HttpLogging(logger)(handleHealth)
	handleHealth = network.RequestMiddleware(handleHealth)
	handleHealth = network.CORSMiddleware(handleHealth)
	mux.Handle("/healthz", handleHealth)
}

func setupProxyRoutes(
	mux *http.ServeMux,
	logger logging.Logger,
	gameProxyHandler *ProxyHandler,
	loggingProxyHandler *ProxyHandler,
) {
	handleGameProxy := wrapProxy(logger, gameProxyHandler)
	handleLoggingProxy := wrapProxy(logger, loggingProxyHandler)

	mux.Handle("/analysis/", handleGameProxy)
	mux.Handle("/chat", handleGameProxy)
	mux.Handle("/interaction", handleGameProxy)
	mux.Handle("/logs/", handleLoggingProxy)
	mux.Handle("/session/", handleGameProxy)
}

func wrapProxy(logger logging.Logger, proxyHandler *ProxyHandler) http.Handler {
	handleProxy := http.Handler(proxyHandler)
	handleProxy = logging.HttpLogging(logger)(handleProxy)
	handleProxy = network.RequestMiddleware(handleProxy)
	handleProxy = network.CORSMiddleware(handleProxy)
	return handleProxy
}
