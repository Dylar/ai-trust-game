package main

import (
	"context"
	"database/sql"
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/auth-service/service"
	"github.com/Dylar/ai-trust-game/services/auth-service/service/user"
	userpostgres "github.com/Dylar/ai-trust-game/services/auth-service/service/user/persistence/postgres"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/infra"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	sharedpostgres "github.com/Dylar/ai-trust-game/services/shared/foundation/persistence/postgres"
)

func main() {
	appEnv := infra.GetEnv("APP_ENV", "dev")

	logger := logging.NewFieldLogger(
		logging.NewConsoleLogger(),
		logging.WithField("service", "auth-service"),
		logging.WithField("env", appEnv),
	)

	userRepo, db, err := newUserRepository(context.Background(), logger)
	if err != nil {
		log.Fatal(err)
	}
	if db != nil {
		defer db.Close()
	}

	healthHandler := service.NewHealthHandler()
	userHandler := service.NewUserHandler(userRepo)

	srv := infra.NewServer(
		logger,
		infra.Config{
			HTTP: []infra.HTTPConfig{
				{
					Name: "auth-service",
					Port: infra.GetEnv("PORT", infra.DefaultPort),
					Register: func(mux *http.ServeMux) {
						service.SetupRoutes(mux, logger, healthHandler, userHandler)
					},
				},
			},
		})

	err = srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}

func newUserRepository(ctx context.Context, logger logging.Logger) (user.Repository, *sql.DB, error) {
	cfg := sharedpostgres.ConfigFromEnv()
	if cfg.DatabaseURL == "" {
		logger.Info(ctx, "auth-service using in-memory user repository")
		return user.NewInMemoryRepository(), nil, nil
	}

	db, err := sharedpostgres.Open(ctx, cfg)
	if err != nil {
		return nil, nil, err
	}

	logger.Info(ctx, "auth-service using postgres user repository")
	return userpostgres.NewRepository(db), db, nil
}
