package service

import (
	"context"
	"encoding/json"
	"time"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/messaging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/messaging/rabbitmq"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
)

const (
	DefaultClientLogsRabbitMQURL        = rabbitmq.DefaultURL
	DefaultClientLogsRabbitMQExchange   = "client.logs"
	DefaultClientLogsRabbitMQQueue      = "logging-service.client-logs"
	DefaultClientLogsRabbitMQRoutingKey = "client.log"
	DefaultClientLogsRabbitMQRetryDelay = 5000
)

type ClientLogsRabbitMQConfig struct {
	URL        string
	Exchange   string
	Queue      string
	RoutingKey string

	RetryExchange      string
	RetryQueue         string
	RetryDelayMillis   int
	DeadLetterExchange string
	DeadLetterQueue    string
}

func (cfg ClientLogsRabbitMQConfig) withDefaults() ClientLogsRabbitMQConfig {
	if cfg.URL == "" {
		cfg.URL = DefaultClientLogsRabbitMQURL
	}
	if cfg.Exchange == "" {
		cfg.Exchange = DefaultClientLogsRabbitMQExchange
	}
	if cfg.Queue == "" {
		cfg.Queue = DefaultClientLogsRabbitMQQueue
	}
	if cfg.RoutingKey == "" {
		cfg.RoutingKey = DefaultClientLogsRabbitMQRoutingKey
	}
	if cfg.RetryExchange == "" {
		cfg.RetryExchange = cfg.Exchange + ".retry"
	}
	if cfg.RetryQueue == "" {
		cfg.RetryQueue = cfg.Queue + ".retry"
	}
	if cfg.RetryDelayMillis == 0 {
		cfg.RetryDelayMillis = DefaultClientLogsRabbitMQRetryDelay
	}
	if cfg.DeadLetterExchange == "" {
		cfg.DeadLetterExchange = cfg.Exchange + ".dead-letter"
	}
	if cfg.DeadLetterQueue == "" {
		cfg.DeadLetterQueue = cfg.Queue + ".dead-letter"
	}
	return cfg
}

type clientLogEnvelope struct {
	Request  ClientLogRequest `json:"request"`
	Metadata network.Metadata `json:"metadata"`
}

type RabbitMQClientLogSink struct {
	publisher messaging.PublisherCloser
}

func NewRabbitMQClientLogSink(cfg ClientLogsRabbitMQConfig) (*RabbitMQClientLogSink, error) {
	cfg = cfg.withDefaults()
	publisher, err := rabbitmq.NewPublisher(rabbitmq.PublisherConfig{
		URL: cfg.URL, Exchange: cfg.Exchange, RoutingKey: cfg.RoutingKey,
	})
	if err != nil {
		return nil, err
	}
	return &RabbitMQClientLogSink{publisher: publisher}, nil
}

func (sink *RabbitMQClientLogSink) WriteClientLog(ctx context.Context, req ClientLogRequest) error {
	body, err := json.Marshal(clientLogEnvelope{Request: req, Metadata: network.GetMetadata(ctx)})
	if err != nil {
		return err
	}
	return sink.publisher.Publish(ctx, messaging.Message{ContentType: "application/json", Body: body})
}

func (sink *RabbitMQClientLogSink) Close() error {
	return sink.publisher.Close()
}

type RabbitMQClientLogConsumer struct {
	consumer messaging.ConsumerCloser
}

func NewRabbitMQClientLogConsumer(
	cfg ClientLogsRabbitMQConfig,
	sink ClientLogSink,
	logger logging.Logger,
) (*RabbitMQClientLogConsumer, error) {
	cfg = cfg.withDefaults()
	consumer, err := rabbitmq.NewConsumer(rabbitmq.ConsumerConfig{
		URL: cfg.URL, Exchange: cfg.Exchange, Queue: cfg.Queue, RoutingKey: cfg.RoutingKey,
		RetryExchange: cfg.RetryExchange, RetryQueue: cfg.RetryQueue,
		RetryDelay:         time.Duration(cfg.RetryDelayMillis) * time.Millisecond,
		DeadLetterExchange: cfg.DeadLetterExchange, DeadLetterQueue: cfg.DeadLetterQueue,
	}, clientLogMessageHandler(sink), logger)
	if err != nil {
		return nil, err
	}
	return &RabbitMQClientLogConsumer{consumer: consumer}, nil
}

func clientLogMessageHandler(sink ClientLogSink) messaging.Handler {
	return func(ctx context.Context, message messaging.Message) error {
		var envelope clientLogEnvelope
		if err := json.Unmarshal(message.Body, &envelope); err != nil {
			return messaging.Reject(err)
		}
		if err := ValidateClientLog(envelope.Request); err != nil {
			return messaging.Reject(err)
		}
		return sink.WriteClientLog(network.WithMetadata(ctx, envelope.Metadata), envelope.Request)
	}
}

func (consumer *RabbitMQClientLogConsumer) Run(ctx context.Context) error {
	return consumer.consumer.Run(ctx)
}

func (consumer *RabbitMQClientLogConsumer) Close() error {
	return consumer.consumer.Close()
}
