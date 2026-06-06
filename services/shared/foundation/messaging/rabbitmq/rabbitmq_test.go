package rabbitmq

import (
	"errors"
	"testing"
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
