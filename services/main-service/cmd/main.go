package main

import (
	"github.com/Dylar/ai-trust-game/internal/interaction"
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/internal/session"
	"github.com/Dylar/ai-trust-game/pkg/audit"
	"github.com/Dylar/ai-trust-game/pkg/infra"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/services/main-service/service"
)

func main() {
	var logger logging.Logger = logging.NewConsoleLogger()
	logger = logging.WithFields(logger,
		logging.WithField("service", "main-service"),
		logging.WithField("env", "dev"),
	)

	auditSink := audit.NewConsoleSink()
	chatHandler := service.NewChatHandler(logger, auditSink)

	sessionRepo := session.NewInMemoryRepository()
	startSessionHandler := service.NewStartSessionHandler(logger, sessionRepo)

	processor := interaction.NewStaticProcessor()
	interactionHandler := service.NewInteractionHandler(logger, sessionRepo, processor)

	srv := infra.NewServer(
		logger,
		infra.Config{
			HTTP: []infra.HTTPConfig{
				{
					Name: "main-service",
					Port: infra.GetEnv("PORT", infra.DefaultPort),
					Register: func(mux *http.ServeMux) {
						service.SetupRoutes(mux, logger, chatHandler, startSessionHandler, interactionHandler)
					},
				},
			},
		})

	err := srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
