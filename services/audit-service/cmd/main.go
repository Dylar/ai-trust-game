package main

import (
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/audit-service/service"
	"github.com/Dylar/ai-trust-game/services/audit-service/service/audit"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/infra"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
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
		})

	err := srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
