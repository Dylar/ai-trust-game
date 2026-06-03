package main

import (
	"context"
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/audit-service/service"
	"github.com/Dylar/ai-trust-game/services/audit-service/service/audit"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/infra"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	sharedaudit "github.com/Dylar/ai-trust-game/services/shared/project/audit"
)

func main() {
	appEnv := infra.GetEnv("APP_ENV", "dev")

	logger := logging.NewFieldLogger(
		logging.NewConsoleLogger(),
		logging.WithField("service", "audit-service"),
		logging.WithField("env", appEnv),
	)

	requestAnalysisRepo := audit.NewInMemoryRequestAnalysisRepository()
	intentSummarizer := newConfiguredIntentSummarizer(logger)
	auditSink := audit.NewAnalyzingSinkWithSummarizer(audit.NewConsoleSink(), requestAnalysisRepo, intentSummarizer)
	consumer, err := sharedaudit.NewRabbitMQConsumer(
		sharedaudit.RabbitMQConfig{
			URL:        infra.GetEnv("RABBITMQ_URL", sharedaudit.DefaultRabbitMQURL),
			Exchange:   infra.GetEnv("AUDIT_EVENTS_EXCHANGE", sharedaudit.DefaultRabbitMQExchange),
			Queue:      infra.GetEnv("AUDIT_EVENTS_QUEUE", sharedaudit.DefaultRabbitMQQueue),
			RoutingKey: infra.GetEnv("AUDIT_EVENTS_ROUTING_KEY", sharedaudit.DefaultRabbitMQRoutingKey),
		},
		auditSink,
		logger,
	)
	if err != nil {
		log.Fatal(err)
	}

	consumerCtx, cancelConsumer := context.WithCancel(context.Background())
	defer cancelConsumer()
	go func() {
		if err := consumer.Run(consumerCtx); err != nil {
			logger.Error(context.Background(), "audit rabbitmq consumer stopped", logging.WithError(err))
		}
	}()

	healthHandler := service.NewHealthHandler()
	eventHandler := service.NewEventHandler(auditSink)
	requestAnalysisHandler := service.NewRequestAnalysisHandlerWithSummarizer(requestAnalysisRepo, intentSummarizer)

	srv := infra.NewServer(
		logger,
		infra.Config{
			HTTP: []infra.HTTPConfig{
				{
					Name: "audit-service",
					Port: infra.GetEnv("PORT", infra.DefaultPort),
					Register: func(mux *http.ServeMux) {
						service.SetupRoutes(mux, logger, healthHandler, eventHandler, requestAnalysisHandler)
					},
				},
			},
			Shutdown: func(context.Context) error {
				cancelConsumer()
				return consumer.Close()
			},
		})

	err = srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
