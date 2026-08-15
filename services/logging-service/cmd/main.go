package main

import (
	"context"
	"log"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/logging-service/service"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/infra"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
)

func main() {
	appEnv := infra.GetEnv("APP_ENV", "dev")

	logger := logging.NewFieldLogger(
		logging.NewConsoleLogger(),
		logging.WithField("service", "logging-service"),
		logging.WithField("env", appEnv),
	)
	queueConfig := service.ClientLogsRabbitMQConfig{
		URL:                infra.GetEnv("RABBITMQ_URL", service.DefaultClientLogsRabbitMQURL),
		Exchange:           infra.GetEnv("CLIENT_LOGS_EXCHANGE", service.DefaultClientLogsRabbitMQExchange),
		Queue:              infra.GetEnv("CLIENT_LOGS_QUEUE", service.DefaultClientLogsRabbitMQQueue),
		RoutingKey:         infra.GetEnv("CLIENT_LOGS_ROUTING_KEY", service.DefaultClientLogsRabbitMQRoutingKey),
		RetryExchange:      infra.GetEnv("CLIENT_LOGS_RETRY_EXCHANGE", ""),
		RetryQueue:         infra.GetEnv("CLIENT_LOGS_RETRY_QUEUE", ""),
		RetryDelayMillis:   infra.GetEnvInt("CLIENT_LOGS_RETRY_DELAY_MILLIS", service.DefaultClientLogsRabbitMQRetryDelay),
		DeadLetterExchange: infra.GetEnv("CLIENT_LOGS_DEAD_LETTER_EXCHANGE", ""),
		DeadLetterQueue:    infra.GetEnv("CLIENT_LOGS_DEAD_LETTER_QUEUE", ""),
	}

	queueSink, err := service.NewRabbitMQClientLogSink(queueConfig)
	if err != nil {
		log.Fatal(err)
	}
	workerSink := service.NewStructuredClientLogSink(logger)
	consumer, err := service.NewRabbitMQClientLogConsumer(queueConfig, workerSink, logger)
	if err != nil {
		_ = queueSink.Close()
		log.Fatal(err)
	}

	consumerCtx, cancelConsumer := context.WithCancel(context.Background())
	defer cancelConsumer()
	go func() {
		if err := consumer.Run(consumerCtx); err != nil {
			logger.Error(context.Background(), "client log rabbitmq consumer stopped", logging.WithError(err))
		}
	}()

	healthHandler := service.NewHealthHandler()
	clientLogHandler := service.NewClientLogHandler(queueSink)

	srv := infra.NewServer(
		logger,
		infra.Config{
			HTTP: []infra.HTTPConfig{
				{
					Name: "logging-service",
					Port: infra.GetEnv("PORT", infra.DefaultPort),
					Register: func(mux *http.ServeMux) {
						service.SetupRoutes(mux, logger, healthHandler, clientLogHandler)
					},
				},
			},
			Shutdown: func(context.Context) error {
				cancelConsumer()
				consumerErr := consumer.Close()
				publisherErr := queueSink.Close()
				if consumerErr != nil {
					return consumerErr
				}
				return publisherErr
			},
		})

	err = srv.Run()
	if err != nil {
		log.Fatal(err)
	}
}
