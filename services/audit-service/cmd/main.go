package main

import (
	"context"
	"database/sql"
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/audit-service/service"
	"github.com/Dylar/ai-trust-game/services/audit-service/service/audit"
	auditpostgres "github.com/Dylar/ai-trust-game/services/audit-service/service/audit/persistence/postgres"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/infra"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	sharedpostgres "github.com/Dylar/ai-trust-game/services/shared/foundation/persistence/postgres"
	sharedaudit "github.com/Dylar/ai-trust-game/services/shared/project/audit"
)

func main() {
	appEnv := infra.GetEnv("APP_ENV", "dev")

	logger := logging.NewFieldLogger(
		logging.NewConsoleLogger(),
		logging.WithField("service", "audit-service"),
		logging.WithField("env", appEnv),
	)

	eventRepo, requestAnalysisRepo, db, err := newPersistenceRepositories(context.Background(), logger)
	if err != nil {
		log.Fatal(err)
	}
	if db != nil {
		defer db.Close()
	}

	intentSummarizer := newConfiguredIntentSummarizer(logger)
	auditSink := audit.NewAnalyzingSinkWithStores(
		audit.NewConsoleSink(),
		eventRepo,
		requestAnalysisRepo,
		intentSummarizer,
	)
	consumer, err := sharedaudit.NewRabbitMQConsumer(
		sharedaudit.RabbitMQConfig{
			URL:                infra.GetEnv("RABBITMQ_URL", sharedaudit.DefaultRabbitMQURL),
			Exchange:           infra.GetEnv("AUDIT_EVENTS_EXCHANGE", sharedaudit.DefaultRabbitMQExchange),
			Queue:              infra.GetEnv("AUDIT_EVENTS_QUEUE", sharedaudit.DefaultRabbitMQQueue),
			RoutingKey:         infra.GetEnv("AUDIT_EVENTS_ROUTING_KEY", sharedaudit.DefaultRabbitMQRoutingKey),
			RetryExchange:      infra.GetEnv("AUDIT_EVENTS_RETRY_EXCHANGE", ""),
			RetryQueue:         infra.GetEnv("AUDIT_EVENTS_RETRY_QUEUE", ""),
			RetryDelayMillis:   infra.GetEnvInt("AUDIT_EVENTS_RETRY_DELAY_MILLIS", sharedaudit.DefaultRabbitMQRetryDelay),
			DeadLetterExchange: infra.GetEnv("AUDIT_EVENTS_DEAD_LETTER_EXCHANGE", ""),
			DeadLetterQueue:    infra.GetEnv("AUDIT_EVENTS_DEAD_LETTER_QUEUE", ""),
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

func newPersistenceRepositories(
	ctx context.Context,
	logger logging.Logger,
) (audit.EventRepository, audit.RequestAnalysisRepository, *sql.DB, error) {
	cfg := sharedpostgres.ConfigFromEnv()
	if cfg.DatabaseURL == "" {
		logger.Info(ctx, "audit-service using in-memory persistence repositories")
		return audit.NewInMemoryEventRepository(), audit.NewInMemoryRequestAnalysisRepository(), nil, nil
	}

	db, err := sharedpostgres.Open(ctx, cfg)
	if err != nil {
		return nil, nil, nil, err
	}

	logger.Info(ctx, "audit-service using postgres persistence repositories")
	return auditpostgres.NewEventRepository(db), auditpostgres.NewRequestAnalysisRepository(db), db, nil
}
