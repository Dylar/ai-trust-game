package audit

import (
	"testing"

	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

func TestRabbitMQConfigWithDefaults(t *testing.T) {
	type Given struct {
		cfg RabbitMQConfig
	}

	type Then struct {
		expectedURL        string
		expectedExchange   string
		expectedQueue      string
		expectedRoutingKey string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN empty RabbitMQ config " +
				"WHEN withDefaults is called " +
				"THEN fills audit route values",
			given: Given{cfg: RabbitMQConfig{}},
			then: Then{
				expectedURL:        DefaultRabbitMQURL,
				expectedExchange:   DefaultRabbitMQExchange,
				expectedQueue:      DefaultRabbitMQQueue,
				expectedRoutingKey: DefaultRabbitMQRoutingKey,
			},
		},
		{
			name: "GIVEN explicit RabbitMQ config " +
				"WHEN withDefaults is called " +
				"THEN keeps explicit audit route values",
			given: Given{cfg: RabbitMQConfig{
				URL:        "amqp://guest:guest@rabbitmq:5672/",
				Exchange:   "custom.exchange",
				Queue:      "custom.queue",
				RoutingKey: "custom.key",
			}},
			then: Then{
				expectedURL:        "amqp://guest:guest@rabbitmq:5672/",
				expectedExchange:   "custom.exchange",
				expectedQueue:      "custom.queue",
				expectedRoutingKey: "custom.key",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			cfg := given.cfg.withDefaults()

			assert.Equal(t, cfg.URL, then.expectedURL, "unexpected url")
			assert.Equal(t, cfg.Exchange, then.expectedExchange, "unexpected exchange")
			assert.Equal(t, cfg.Queue, then.expectedQueue, "unexpected queue")
			assert.Equal(t, cfg.RoutingKey, then.expectedRoutingKey, "unexpected routing key")
		})
	}
}
