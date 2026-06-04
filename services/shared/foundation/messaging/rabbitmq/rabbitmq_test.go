package rabbitmq

import (
	"errors"
	"testing"
)

func TestPublisherRequiresURL(t *testing.T) {
	_, err := NewPublisher(PublisherConfig{})

	if !errors.Is(err, ErrMissingURL) {
		t.Fatalf("expected ErrMissingURL, got %v", err)
	}
}

func TestConsumerRequiresURL(t *testing.T) {
	_, err := NewConsumer(ConsumerConfig{}, nil, nil)

	if !errors.Is(err, ErrMissingURL) {
		t.Fatalf("expected ErrMissingURL, got %v", err)
	}
}
