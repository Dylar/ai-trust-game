package main

import (
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/gateway-service/service"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/infra"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
)

func main() {
	appEnv := infra.GetEnv("APP_ENV", "dev")

	logger := logging.NewFieldLogger(
		logging.NewConsoleLogger(),
		logging.WithField("service", "gateway-service"),
		logging.WithField("env", appEnv),
	)

	gameServiceURL := infra.GetEnv("GAME_SERVICE_URL", "http://game-service:8080")
	gameProxyHandler, err := service.NewProxyHandler(gameServiceURL)
	if err != nil {
		log.Fatal(err)
	}

	loggingServiceURL := infra.GetEnv("LOGGING_SERVICE_URL", "http://logging-service:8080")
	loggingProxyHandler, err := service.NewProxyHandler(loggingServiceURL)
	if err != nil {
		log.Fatal(err)
	}

	auditServiceURL := infra.GetEnv("AUDIT_SERVICE_URL", "http://audit-service:8080")
	auditProxyHandler, err := service.NewProxyHandler(auditServiceURL)
	if err != nil {
		log.Fatal(err)
	}

	healthHandler := service.NewHealthHandler()
	srv := infra.NewServer(
		logger,
		infra.Config{
			HTTP: []infra.HTTPConfig{
				{
					Name: "gateway-service",
					Port: infra.GetEnv("PORT", infra.DefaultPort),
					Register: func(mux *http.ServeMux) {
						service.SetupRoutes(mux, logger, healthHandler, gameProxyHandler, loggingProxyHandler, auditProxyHandler)
					},
				},
			},
		})

	err = srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
