package rabbitmq

import (
	"errors"
	"testing"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
)

func TestPublisherRequiresURL(t *testing.T) {
	type Given struct {
		create func() error
	}

	type Then struct {
		expectedError error
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN publisher config without URL " +
				"WHEN NewPublisher is called " +
				"THEN returns ErrMissingURL",
			given: Given{create: func() error {
				_, err := NewPublisher(PublisherConfig{})
				return err
			}},
			then: Then{expectedError: ErrMissingURL},
		},
		{
			name: "GIVEN consumer config without URL " +
				"WHEN NewConsumer is called " +
				"THEN returns ErrMissingURL",
			given: Given{create: func() error {
				_, err := NewConsumer(ConsumerConfig{}, nil, nil)
				return err
			}},
			then: Then{expectedError: ErrMissingURL},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			err := given.create()

			if !errors.Is(err, then.expectedError) {
				t.Fatalf("expected error %v, got %v", then.expectedError, err)
			}
		})
	}
}

func TestConsumerConfigWithDefaults(t *testing.T) {
	type Given struct {
		cfg ConsumerConfig
	}

	type Then struct {
		expectedRetryExchange      string
		expectedRetryQueue         string
		expectedRetryDelay         time.Duration
		expectedDeadLetterExchange string
		expectedDeadLetterQueue    string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN consumer route config " +
				"WHEN withDefaults is called " +
				"THEN derives retry and dead-letter route names",
			given: Given{cfg: ConsumerConfig{
				Exchange: "audit.events",
				Queue:    "audit-service.audit-events",
			}},
			then: Then{
				expectedRetryExchange:      "audit.events.retry",
				expectedRetryQueue:         "audit-service.audit-events.retry",
				expectedRetryDelay:         5 * time.Second,
				expectedDeadLetterExchange: "audit.events.dead-letter",
				expectedDeadLetterQueue:    "audit-service.audit-events.dead-letter",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			cfg := given.cfg.withDefaults()

			if cfg.RetryExchange != then.expectedRetryExchange {
				t.Fatalf("expected retry exchange %q, got %q", then.expectedRetryExchange, cfg.RetryExchange)
			}
			if cfg.RetryQueue != then.expectedRetryQueue {
				t.Fatalf("expected retry queue %q, got %q", then.expectedRetryQueue, cfg.RetryQueue)
			}
			if cfg.RetryDelay != then.expectedRetryDelay {
				t.Fatalf("expected retry delay %s, got %s", then.expectedRetryDelay, cfg.RetryDelay)
			}
			if cfg.DeadLetterExchange != then.expectedDeadLetterExchange {
				t.Fatalf("expected dead-letter exchange %q, got %q", then.expectedDeadLetterExchange, cfg.DeadLetterExchange)
			}
			if cfg.DeadLetterQueue != then.expectedDeadLetterQueue {
				t.Fatalf("expected dead-letter queue %q, got %q", then.expectedDeadLetterQueue, cfg.DeadLetterQueue)
			}
		})
	}
}

func TestQueueArguments(t *testing.T) {
	type Given struct {
		cfg ConsumerConfig
	}

	type Then struct {
		expectedMainDeadLetterExchange  string
		expectedRetryTTL                int32
		expectedRetryDeadLetterExchange string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN consumer config with retry and dead-letter defaults " +
				"WHEN queue arguments are built " +
				"THEN main queue dead-letters and retry queue returns to main exchange",
			given: Given{cfg: ConsumerConfig{
				Exchange:   "audit.events",
				Queue:      "audit-service.audit-events",
				RoutingKey: "audit.event",
			}.withDefaults()},
			then: Then{
				expectedMainDeadLetterExchange:  "audit.events.dead-letter",
				expectedRetryTTL:                int32(5000),
				expectedRetryDeadLetterExchange: "audit.events",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			mainArgs := mainQueueArguments(given.cfg)
			retryArgs := retryQueueArguments(given.cfg)

			if mainArgs["x-dead-letter-exchange"] != then.expectedMainDeadLetterExchange {
				t.Fatalf("unexpected main dead-letter exchange: %v", mainArgs)
			}
			if retryArgs["x-message-ttl"] != then.expectedRetryTTL {
				t.Fatalf("unexpected retry ttl: %v", retryArgs)
			}
			if retryArgs["x-dead-letter-exchange"] != then.expectedRetryDeadLetterExchange {
				t.Fatalf("unexpected retry dead-letter exchange: %v", retryArgs)
			}
			if _, ok := retryArgs["x-dead-letter-routing-key"].(string); !ok {
				t.Fatalf("expected retry dead-letter routing key in args: %v", retryArgs)
			}
		})
	}
}

func TestPersistentDeliveryMode(t *testing.T) {
	publishing := persistentPublishing("application/json", []byte(`{"ok":true}`), nil)

	if publishing.DeliveryMode != amqp.Persistent {
		t.Fatalf("expected persistent delivery mode, got %d", publishing.DeliveryMode)
	}
}
