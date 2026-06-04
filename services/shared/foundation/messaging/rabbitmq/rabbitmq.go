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
		amqp.Publishing{
			ContentType:  message.ContentType,
			DeliveryMode: amqp.Persistent,
			Timestamp:    time.Now(),
			Body:         message.Body,
		},
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
	queue   string
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

	if err := declareRoute(channel, cfg); err != nil {
		_ = channel.Close()
		_ = conn.Close()
		return nil, err
	}

	return &Consumer{
		conn:    conn,
		channel: channel,
		queue:   cfg.Queue,
		handler: handler,
		logger:  logger,
	}, nil
}

func (consumer *Consumer) Run(ctx context.Context) error {
	deliveries, err := consumer.channel.Consume(
		consumer.queue,
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
		_ = delivery.Nack(false, messaging.ShouldRequeue(err))
		return
	}

	_ = delivery.Ack(false)
}

func declareRoute(channel *amqp.Channel, cfg ConsumerConfig) error {
	if err := declareExchange(channel, cfg.Exchange); err != nil {
		return err
	}

	if _, err := channel.QueueDeclare(
		cfg.Queue,
		true,
		false,
		false,
		false,
		nil,
	); err != nil {
		return err
	}

	return channel.QueueBind(
		cfg.Queue,
		cfg.RoutingKey,
		cfg.Exchange,
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
