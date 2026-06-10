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
	userHandler *UserHandler,
) {
	setupHealthRoute(mux, logger, healthHandler)
	setupUsersRoute(mux, logger, userHandler)
	setupUserSelectRoute(mux, logger, userHandler)
}

func setupHealthRoute(mux *http.ServeMux, logger logging.Logger, healthHandler *HealthHandler) {
	handleHealth := http.Handler(healthHandler)
	handleHealth = logging.HttpLogging(logger)(handleHealth)
	handleHealth = network.RequestMiddleware(handleHealth)
	handleHealth = network.CORSMiddleware(handleHealth)
	mux.Handle("/healthz", handleHealth)
}

func setupUsersRoute(mux *http.ServeMux, logger logging.Logger, userHandler *UserHandler) {
	handleUsers := http.Handler(http.HandlerFunc(userHandler.ServeUsersHTTP))
	handleUsers = logging.HttpLogging(logger)(handleUsers)
	handleUsers = network.RequestMiddleware(handleUsers)
	handleUsers = network.CORSMiddleware(handleUsers)
	mux.Handle("/users", handleUsers)
}

func setupUserSelectRoute(mux *http.ServeMux, logger logging.Logger, userHandler *UserHandler) {
	handleUserSelect := http.Handler(http.HandlerFunc(userHandler.ServeUserSelectHTTP))
	handleUserSelect = logging.HttpLogging(logger)(handleUserSelect)
	handleUserSelect = network.RequestMiddleware(handleUserSelect)
	handleUserSelect = network.CORSMiddleware(handleUserSelect)
	mux.Handle("/users/select", handleUserSelect)
}
