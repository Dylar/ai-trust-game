package main

import (
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/game-service/service"
	"github.com/Dylar/ai-trust-game/services/game-service/service/audit"
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

	requestAnalysisRepo := audit.NewInMemoryRequestAnalysisRepository()
	intentSummarizer := newConfiguredIntentSummarizer(logger)
	auditSink := audit.NewAnalyzingSinkWithSummarizer(audit.NewConsoleSink(), requestAnalysisRepo, intentSummarizer)
	healthHandler := service.NewHealthHandler()
	chatHandler := service.NewChatHandler(logger, auditSink)
	requestAnalysisHandler := service.NewRequestAnalysisHandlerWithSummarizer(requestAnalysisRepo, intentSummarizer)

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
						service.SetupRoutes(mux, logger, healthHandler, chatHandler, startSessionHandler, interactionHandler, requestAnalysisHandler)
					},
				},
			},
		})

	err := srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
