package main

import (
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/logging-service/service"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/infra"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
)

func main() {
	appEnv := infra.GetEnv("APP_ENV", "dev")

	logger := logging.NewFieldLogger(
		logging.NewConsoleLogger(),
		logging.WithField("service", "logging-service"),
		logging.WithField("env", appEnv),
	)

	healthHandler := service.NewHealthHandler()
	clientLogHandler := service.NewClientLogHandler(logger)

	srv := infra.NewServer(
		logger,
		infra.Config{
			HTTP: []infra.HTTPConfig{
				{
					Name: "logging-service",
					Port: infra.GetEnv("PORT", infra.DefaultPort),
					Register: func(mux *http.ServeMux) {
						service.SetupRoutes(mux, logger, healthHandler, clientLogHandler)
					},
				},
			},
		})

	err := srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
