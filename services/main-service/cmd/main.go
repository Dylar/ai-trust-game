package main

import (
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

	requestAnalysisRepo := audit.NewInMemoryRequestAnalysisRepository()
	auditSink := audit.NewAnalyzingSink(audit.NewConsoleSink(), requestAnalysisRepo)
	chatHandler := service.NewChatHandler(logger, auditSink)
	requestAnalysisHandler := service.NewRequestAnalysisHandler(requestAnalysisRepo)

	sessionRepo := session.NewInMemoryRepository()
	startSessionHandler := service.NewStartSessionHandler(logger, sessionRepo)

	processor := newConfiguredProcessor(logger, auditSink)
	interactionHandler := service.NewInteractionHandler(logger, sessionRepo, processor)

	srv := infra.NewServer(
		logger,
		infra.Config{
			HTTP: []infra.HTTPConfig{
				{
					Name: "main-service",
					Port: infra.GetEnv("PORT", infra.DefaultPort),
					Register: func(mux *http.ServeMux) {
						service.SetupRoutes(mux, logger, chatHandler, startSessionHandler, interactionHandler, requestAnalysisHandler)
					},
				},
			},
		})

	err := srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
