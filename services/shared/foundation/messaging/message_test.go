package messaging

import (
	"errors"
	"testing"
)

func TestShouldRequeue(t *testing.T) {
	type Given struct {
		err error
	}

	type Then struct {
		expectedRequeue bool
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN normal error " +
				"WHEN ShouldRequeue is called " +
				"THEN returns true",
			given: Given{err: errors.New("processing failed")},
			then:  Then{expectedRequeue: true},
		},
		{
			name: "GIVEN rejected message error " +
				"WHEN ShouldRequeue is called " +
				"THEN returns false",
			given: Given{err: Reject(errors.New("invalid payload"))},
			then:  Then{expectedRequeue: false},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			actual := ShouldRequeue(given.err)

			if actual != then.expectedRequeue {
				t.Fatalf("expected requeue %t, got %t", then.expectedRequeue, actual)
			}
		})
	}
}
