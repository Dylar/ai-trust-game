package audit

import (
	"testing"

	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

func TestRabbitMQConfigWithDefaults(t *testing.T) {
	t.Run("fills audit route values", func(t *testing.T) {
		cfg := (RabbitMQConfig{}).withDefaults()

		assert.Equal(t, cfg.URL, DefaultRabbitMQURL, "unexpected url")
		assert.Equal(t, cfg.Exchange, DefaultRabbitMQExchange, "unexpected exchange")
		assert.Equal(t, cfg.Queue, DefaultRabbitMQQueue, "unexpected queue")
		assert.Equal(t, cfg.RoutingKey, DefaultRabbitMQRoutingKey, "unexpected routing key")
	})

	t.Run("keeps explicit audit route values", func(t *testing.T) {
		cfg := (RabbitMQConfig{
			URL:        "amqp://guest:guest@rabbitmq:5672/",
			Exchange:   "custom.exchange",
			Queue:      "custom.queue",
			RoutingKey: "custom.key",
		}).withDefaults()

		assert.Equal(t, cfg.URL, "amqp://guest:guest@rabbitmq:5672/", "unexpected url")
		assert.Equal(t, cfg.Exchange, "custom.exchange", "unexpected exchange")
		assert.Equal(t, cfg.Queue, "custom.queue", "unexpected queue")
		assert.Equal(t, cfg.RoutingKey, "custom.key", "unexpected routing key")
	})
}
