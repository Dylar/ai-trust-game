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
	userHandler *UserHandler,
) {
	setupHealthRoute(mux, logger, healthHandler)
	setupUsersRoute(mux, logger, userHandler)
	setupUserSelectRoute(mux, logger, userHandler)
}

func setupHealthRoute(mux *http.ServeMux, logger logging.Logger, healthHandler *HealthHandler) {
	handleHealth := infra.StandardHTTPHandler(logger, healthHandler)
	mux.Handle("/healthz", handleHealth)
}

func setupUsersRoute(mux *http.ServeMux, logger logging.Logger, userHandler *UserHandler) {
	handleUsers := infra.StandardHTTPHandler(logger, http.HandlerFunc(userHandler.ServeUsersHTTP))
	mux.Handle("/users", handleUsers)
	mux.Handle("/auth/users", handleUsers)
}

func setupUserSelectRoute(mux *http.ServeMux, logger logging.Logger, userHandler *UserHandler) {
	handleUserSelect := infra.StandardHTTPHandler(logger, http.HandlerFunc(userHandler.ServeUserSelectHTTP))
	mux.Handle("/users/select", handleUserSelect)
	mux.Handle("/auth/users/select", handleUserSelect)
}
