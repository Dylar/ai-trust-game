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
	gameProxyHandler *ProxyHandler,
	loggingProxyHandler *ProxyHandler,
	auditProxyHandler *ProxyHandler,
	authProxyHandler *ProxyHandler,
) {
	setupHealthRoute(mux, logger, healthHandler)
	setupProxyRoutes(mux, logger, gameProxyHandler, loggingProxyHandler, auditProxyHandler, authProxyHandler)
}

func setupHealthRoute(mux *http.ServeMux, logger logging.Logger, healthHandler *HealthHandler) {
	handleHealth := infra.StandardHTTPHandler(logger, healthHandler)
	mux.Handle("/healthz", handleHealth)
}

func setupProxyRoutes(
	mux *http.ServeMux,
	logger logging.Logger,
	gameProxyHandler *ProxyHandler,
	loggingProxyHandler *ProxyHandler,
	auditProxyHandler *ProxyHandler,
	authProxyHandler *ProxyHandler,
) {
	handleGameProxy := wrapProxy(logger, gameProxyHandler)
	handleLoggingProxy := wrapProxy(logger, loggingProxyHandler)
	handleAuditProxy := wrapProxy(logger, auditProxyHandler)
	handleAuthProxy := wrapProxy(logger, authProxyHandler)

	mux.Handle("/analysis/", handleAuditProxy)
	mux.Handle("/auth/", handleAuthProxy)
	mux.Handle("/chat", handleGameProxy)
	mux.Handle("/interaction", handleGameProxy)
	mux.Handle("/interaction/", handleGameProxy)
	mux.Handle("/logs/", handleLoggingProxy)
	mux.Handle("/session/", handleGameProxy)
}

func wrapProxy(logger logging.Logger, proxyHandler *ProxyHandler) http.Handler {
	return infra.StandardHTTPHandler(logger, proxyHandler)
}
