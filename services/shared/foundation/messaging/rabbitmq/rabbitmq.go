package rabbitmq

import (
	"context"
	"errors"
	"time"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/messaging"
	amqp "github.com/rabbitmq/amqp091-go"
)

const DefaultURL = "amqp://guest:guest@rabbitmq:5672/"

var ErrMissingURL = errors.New("missing rabbitmq url")

type PublisherConfig struct {
	URL        string
	Exchange   string
	RoutingKey string
}

type ConsumerConfig struct {
	URL        string
	Exchange   string
	Queue      string
	RoutingKey string

	RetryExchange      string
	RetryQueue         string
	RetryDelay         time.Duration
	DeadLetterExchange string
	DeadLetterQueue    string
}

type Publisher struct {
	conn       *amqp.Connection
	channel    *amqp.Channel
	exchange   string
	routingKey string
}

func NewPublisher(cfg PublisherConfig) (*Publisher, error) {
	if cfg.URL == "" {
		return nil, ErrMissingURL
	}

	conn, err := amqp.Dial(cfg.URL)
	if err != nil {
		return nil, err
	}

	channel, err := conn.Channel()
	if err != nil {
		_ = conn.Close()
		return nil, err
	}

	if err := declareExchange(channel, cfg.Exchange); err != nil {
		_ = channel.Close()
		_ = conn.Close()
		return nil, err
	}

	return &Publisher{
		conn:       conn,
		channel:    channel,
		exchange:   cfg.Exchange,
		routingKey: cfg.RoutingKey,
	}, nil
}

func (publisher *Publisher) Publish(ctx context.Context, message messaging.Message) error {
	return publisher.channel.PublishWithContext(
		ctx,
		publisher.exchange,
		publisher.routingKey,
		false,
		false,
		persistentPublishing(message.ContentType, message.Body, nil),
	)
}

func (publisher *Publisher) Close() error {
	err := publisher.channel.Close()
	connErr := publisher.conn.Close()
	if err != nil {
		return err
	}
	return connErr
}

type Consumer struct {
	conn    *amqp.Connection
	channel *amqp.Channel
	cfg     ConsumerConfig
	handler messaging.Handler
	logger  logging.Logger
}

func NewConsumer(cfg ConsumerConfig, handler messaging.Handler, logger logging.Logger) (*Consumer, error) {
	if cfg.URL == "" {
		return nil, ErrMissingURL
	}
	if handler == nil {
		handler = func(context.Context, messaging.Message) error { return nil }
	}
	if logger == nil {
		logger = logging.NewNoopLogger()
	}

	conn, err := amqp.Dial(cfg.URL)
	if err != nil {
		return nil, err
	}

	channel, err := conn.Channel()
	if err != nil {
		_ = conn.Close()
		return nil, err
	}

	cfg = cfg.withDefaults()
	if err := declareRoute(channel, cfg); err != nil {
		_ = channel.Close()
		_ = conn.Close()
		return nil, err
	}

	return &Consumer{
		conn:    conn,
		channel: channel,
		cfg:     cfg,
		handler: handler,
		logger:  logger,
	}, nil
}

func (consumer *Consumer) Run(ctx context.Context) error {
	deliveries, err := consumer.channel.Consume(
		consumer.cfg.Queue,
		"",
		false,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		return err
	}

	for {
		select {
		case <-ctx.Done():
			return nil
		case delivery, ok := <-deliveries:
			if !ok {
				return nil
			}
			consumer.handleDelivery(ctx, delivery)
		}
	}
}

func (consumer *Consumer) Close() error {
	err := consumer.channel.Close()
	connErr := consumer.conn.Close()
	if err != nil {
		return err
	}
	return connErr
}

func (consumer *Consumer) handleDelivery(ctx context.Context, delivery amqp.Delivery) {
	message := messaging.Message{
		ContentType: delivery.ContentType,
		Body:        delivery.Body,
	}

	if err := consumer.handler(ctx, message); err != nil {
		consumer.logger.Error(ctx, "rabbitmq message processing failed", logging.WithError(err))
		if messaging.ShouldRequeue(err) {
			if publishRetry(ctx, consumer.channel, consumer.cfg, delivery) == nil {
				_ = delivery.Ack(false)
				return
			}
		}
		_ = delivery.Nack(false, false)
		return
	}

	_ = delivery.Ack(false)
}

func declareRoute(channel *amqp.Channel, cfg ConsumerConfig) error {
	if err := declareExchange(channel, cfg.Exchange); err != nil {
		return err
	}
	if err := declareExchange(channel, cfg.RetryExchange); err != nil {
		return err
	}
	if err := declareExchange(channel, cfg.DeadLetterExchange); err != nil {
		return err
	}

	if _, err := channel.QueueDeclare(
		cfg.Queue,
		true,
		false,
		false,
		false,
		mainQueueArguments(cfg),
	); err != nil {
		return err
	}
	if _, err := channel.QueueDeclare(
		cfg.RetryQueue,
		true,
		false,
		false,
		false,
		retryQueueArguments(cfg),
	); err != nil {
		return err
	}
	if _, err := channel.QueueDeclare(
		cfg.DeadLetterQueue,
		true,
		false,
		false,
		false,
		nil,
	); err != nil {
		return err
	}

	if err := channel.QueueBind(
		cfg.Queue,
		cfg.RoutingKey,
		cfg.Exchange,
		false,
		nil,
	); err != nil {
		return err
	}
	if err := channel.QueueBind(
		cfg.RetryQueue,
		cfg.RoutingKey,
		cfg.RetryExchange,
		false,
		nil,
	); err != nil {
		return err
	}
	return channel.QueueBind(
		cfg.DeadLetterQueue,
		cfg.RoutingKey,
		cfg.DeadLetterExchange,
		false,
		nil,
	)
}

func declareExchange(channel *amqp.Channel, exchange string) error {
	return channel.ExchangeDeclare(
		exchange,
		"direct",
		true,
		false,
		false,
		false,
		nil,
	)
}

func publishRetry(ctx context.Context, channel *amqp.Channel, cfg ConsumerConfig, delivery amqp.Delivery) error {
	return channel.PublishWithContext(
		ctx,
		cfg.RetryExchange,
		cfg.RoutingKey,
		false,
		false,
		persistentPublishing(delivery.ContentType, delivery.Body, delivery.Headers),
	)
}

func mainQueueArguments(cfg ConsumerConfig) amqp.Table {
	return amqp.Table{
		"x-dead-letter-exchange": cfg.DeadLetterExchange,
	}
}

func retryQueueArguments(cfg ConsumerConfig) amqp.Table {
	return amqp.Table{
		"x-message-ttl":             int32(cfg.RetryDelay / time.Millisecond),
		"x-dead-letter-exchange":    cfg.Exchange,
		"x-dead-letter-routing-key": cfg.RoutingKey,
	}
}

func persistentPublishing(contentType string, body []byte, headers amqp.Table) amqp.Publishing {
	return amqp.Publishing{
		ContentType:  contentType,
		DeliveryMode: amqp.Persistent,
		Timestamp:    time.Now(),
		Body:         body,
		Headers:      headers,
	}
}

func (cfg ConsumerConfig) withDefaults() ConsumerConfig {
	if cfg.RetryExchange == "" {
		cfg.RetryExchange = cfg.Exchange + ".retry"
	}
	if cfg.RetryQueue == "" {
		cfg.RetryQueue = cfg.Queue + ".retry"
	}
	if cfg.RetryDelay == 0 {
		cfg.RetryDelay = 5 * time.Second
	}
	if cfg.DeadLetterExchange == "" {
		cfg.DeadLetterExchange = cfg.Exchange + ".dead-letter"
	}
	if cfg.DeadLetterQueue == "" {
		cfg.DeadLetterQueue = cfg.Queue + ".dead-letter"
	}
	return cfg
}
