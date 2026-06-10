package main

import (
	"context"
	"database/sql"
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/game-service/service"
	"github.com/Dylar/ai-trust-game/services/game-service/service/interaction"
	interactionpostgres "github.com/Dylar/ai-trust-game/services/game-service/service/interaction/persistence/postgres"
	"github.com/Dylar/ai-trust-game/services/game-service/service/session"
	sessionpostgres "github.com/Dylar/ai-trust-game/services/game-service/service/session/persistence/postgres"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/infra"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	sharedpostgres "github.com/Dylar/ai-trust-game/services/shared/foundation/persistence/postgres"
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

	sessionRepo, interactionRepo, db, err := newPersistenceRepositories(context.Background(), logger)
	if err != nil {
		log.Fatal(err)
	}
	if db != nil {
		defer db.Close()
	}

	startSessionHandler := service.NewStartSessionHandler(logger, sessionRepo)
	sessionQueryHandler := service.NewSessionQueryHandler(sessionRepo)

	processor := newConfiguredProcessor(logger, auditSink)
	interactionHandler := service.NewInteractionHandler(logger, sessionRepo, processor, interactionRepo)

	srv := infra.NewServer(
		logger,
		infra.Config{
			HTTP: []infra.HTTPConfig{
				{
					Name: "game-service",
					Port: infra.GetEnv("PORT", infra.DefaultPort),
					Register: func(mux *http.ServeMux) {
						service.SetupRoutes(
							mux,
							logger,
							healthHandler,
							chatHandler,
							startSessionHandler,
							sessionQueryHandler,
							interactionHandler,
						)
					},
				},
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
) (session.Repository, interaction.Repository, *sql.DB, error) {
	cfg := sharedpostgres.ConfigFromEnv()
	if cfg.DatabaseURL == "" {
		logger.Info(ctx, "game-service using in-memory persistence repositories")
		return session.NewInMemoryRepository(), interaction.NewInMemoryRepository(), nil, nil
	}

	db, err := sharedpostgres.Open(ctx, cfg)
	if err != nil {
		return nil, nil, nil, err
	}

	logger.Info(ctx, "game-service using postgres persistence repositories")
	return sessionpostgres.NewRepository(db), interactionpostgres.NewRepository(db), db, nil
}
