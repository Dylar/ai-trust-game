package audit

import (
	"context"
	"encoding/json"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/messaging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/messaging/rabbitmq"
)

const (
	DefaultRabbitMQURL        = rabbitmq.DefaultURL
	DefaultRabbitMQExchange   = "audit.events"
	DefaultRabbitMQQueue      = "audit-service.audit-events"
	DefaultRabbitMQRoutingKey = "audit.event"
)

type RabbitMQConfig struct {
	URL        string
	Exchange   string
	Queue      string
	RoutingKey string
}

func (cfg RabbitMQConfig) withDefaults() RabbitMQConfig {
	if cfg.URL == "" {
		cfg.URL = DefaultRabbitMQURL
	}
	if cfg.Exchange == "" {
		cfg.Exchange = DefaultRabbitMQExchange
	}
	if cfg.Queue == "" {
		cfg.Queue = DefaultRabbitMQQueue
	}
	if cfg.RoutingKey == "" {
		cfg.RoutingKey = DefaultRabbitMQRoutingKey
	}
	return cfg
}

type RabbitMQSink struct {
	publisher messaging.PublisherCloser
}

func NewRabbitMQSink(cfg RabbitMQConfig) (*RabbitMQSink, error) {
	cfg = cfg.withDefaults()

	publisher, err := rabbitmq.NewPublisher(rabbitmq.PublisherConfig{
		URL:        cfg.URL,
		Exchange:   cfg.Exchange,
		RoutingKey: cfg.RoutingKey,
	})
	if err != nil {
		return nil, err
	}

	return &RabbitMQSink{publisher: publisher}, nil
}

func (sink *RabbitMQSink) WriteEvent(ctx context.Context, event Event) error {
	body, err := json.Marshal(event)
	if err != nil {
		return err
	}

	return sink.publisher.Publish(ctx, messaging.Message{
		ContentType: "application/json",
		Body:        body,
	})
}

func (sink *RabbitMQSink) Close() error {
	return sink.publisher.Close()
}

type RabbitMQConsumer struct {
	consumer messaging.ConsumerCloser
}

func NewRabbitMQConsumer(cfg RabbitMQConfig, sink Sink, logger logging.Logger) (*RabbitMQConsumer, error) {
	cfg = cfg.withDefaults()
	if sink == nil {
		sink = NewNoopSink()
	}

	consumer, err := rabbitmq.NewConsumer(
		rabbitmq.ConsumerConfig{
			URL:        cfg.URL,
			Exchange:   cfg.Exchange,
			Queue:      cfg.Queue,
			RoutingKey: cfg.RoutingKey,
		},
		func(ctx context.Context, message messaging.Message) error {
			var event Event
			if err := json.Unmarshal(message.Body, &event); err != nil {
				return messaging.Reject(err)
			}
			return sink.WriteEvent(ctx, event)
		},
		logger,
	)
	if err != nil {
		return nil, err
	}

	return &RabbitMQConsumer{consumer: consumer}, nil
}

func (consumer *RabbitMQConsumer) Run(ctx context.Context) error {
	return consumer.consumer.Run(ctx)
}

func (consumer *RabbitMQConsumer) Close() error {
	return consumer.consumer.Close()
}
