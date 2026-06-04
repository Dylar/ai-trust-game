package main

import (
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/game-service/service"
	"github.com/Dylar/ai-trust-game/services/game-service/service/session"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/infra"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/project/audit"
)

func main() {
	appEnv := infra.GetEnv("APP_ENV", "dev")

	logger := logging.NewFieldLogger(
		logging.NewConsoleLogger(),
		logging.WithField("service", "game-service"),
		logging.WithField("env", appEnv),
	)

	auditSink, err := audit.NewRabbitMQSink(audit.RabbitMQConfig{
		URL:        infra.GetEnv("RABBITMQ_URL", audit.DefaultRabbitMQURL),
		Exchange:   infra.GetEnv("AUDIT_EVENTS_EXCHANGE", audit.DefaultRabbitMQExchange),
		RoutingKey: infra.GetEnv("AUDIT_EVENTS_ROUTING_KEY", audit.DefaultRabbitMQRoutingKey),
	})
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		_ = auditSink.Close()
	}()

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
