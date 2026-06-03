package main

import (
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/game-service/service"
	auditclient "github.com/Dylar/ai-trust-game/services/game-service/service/audit_client"
	"github.com/Dylar/ai-trust-game/services/game-service/service/session"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/infra"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
)

func main() {
	appEnv := infra.GetEnv("APP_ENV", "dev")

	logger := logging.NewFieldLogger(
		logging.NewConsoleLogger(),
		logging.WithField("service", "game-service"),
		logging.WithField("env", appEnv),
	)

	auditServiceURL := infra.GetEnv("AUDIT_SERVICE_URL", "http://audit-service:8080")
	auditSink, err := auditclient.NewHTTPSink(http.DefaultClient, auditServiceURL)
	if err != nil {
		log.Fatal(err)
	}

	healthHandler := service.NewHealthHandler()
	chatHandler := service.NewChatHandler(logger, auditSink)

	sessionRepo := session.NewInMemoryRepository()
	startSessionHandler := service.NewStartSessionHandler(logger, sessionRepo)

	processor := newConfiguredProcessor(logger, auditSink)
	interactionHandler := service.NewInteractionHandler(logger, sessionRepo, processor)

	srv := infra.NewServer(
		logger,
		infra.Config{
			HTTP: []infra.HTTPConfig{
				{
					Name: "game-service",
					Port: infra.GetEnv("PORT", infra.DefaultPort),
					Register: func(mux *http.ServeMux) {
						service.SetupRoutes(mux, logger, healthHandler, chatHandler, startSessionHandler, interactionHandler)
					},
				},
			},
		})

	err = srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
