package main

import (
	"github.com/Dylar/ai-trust-game/pkg/infra"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/services/main-service/service"
	"log"
	"net/http"
)

func main() {
	var logger logging.Logger = logging.NewConsoleLogger()
	logger = logging.WithFields(logger,
		logging.WithField("service", "main-service"),
		logging.WithField("env", "dev"),
	)

	chatHandler := service.NewChatHandler(logger)

	srv := infra.NewServer(
		logger,
		infra.Config{
			HTTP: []infra.HTTPConfig{
				{
					Name: "main-service",
					Port: infra.GetEnv("PORT", infra.DefaultPort),
					Register: func(mux *http.ServeMux) {
						service.SetupRoutes(mux, logger, chatHandler)
					},
				},
			},
		})

	err := srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
