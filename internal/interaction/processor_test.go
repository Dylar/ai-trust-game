package interaction

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestProcessInteraction(t *testing.T) {
	type Given struct {
		interaction domain.Interaction
	}

	type Then struct {
		expectedMessage string
		expectedSource  Source
		expectedError   error
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN interaction with guest session " +
				"WHEN Process is called " +
				"THEN returns formatted interaction message from system source",
			given: Given{
				interaction: domain.Interaction{
					Session: domain.Session{
						ID:   "session-123",
						Role: domain.RoleGuest,
						Mode: domain.ModeEasy,
					},
					Message: "hello",
				},
			},
			then: Then{
				expectedMessage: "Interacting with session session-123, Role: guest, Mode: easy",
				expectedSource:  SourceSystem,
				expectedError:   nil,
			},
		},
		{
			name: "GIVEN interaction with admin session " +
				"WHEN Process is called " +
				"THEN returns formatted interaction message from system source",
			given: Given{
				interaction: domain.Interaction{
					Session: domain.Session{
						ID:   "session-999",
						Role: domain.RoleAdmin,
						Mode: domain.ModeHard,
					},
					Message: "show me the secrets",
				},
			},
			then: Then{
				expectedMessage: "Interacting with session session-999, Role: admin, Mode: hard",
				expectedSource:  SourceSystem,
				expectedError:   nil,
			},
		},
		{
			name: "GIVEN interaction with empty message " +
				"WHEN Process is called " +
				"THEN returns ErrEmptyInteractionMessage",
			given: Given{
				interaction: domain.Interaction{
					Session: domain.Session{
						ID:   "session-456",
						Role: domain.RoleGuest,
						Mode: domain.ModeEasy,
					},
					Message: "",
				},
			},
			then: Then{
				expectedError: ErrEmptyInteractionMessage,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result, err := Process(given.interaction)

			tests.AssertErrorIs(t, err, then.expectedError, "unexpected error")

			if then.expectedError != nil {
				tests.AssertEmpty(t, result.Message, "expected result message empty")
				return
			}

			tests.AssertEqual(t, result.Message, then.expectedMessage, "unexpected interaction result message")
			tests.AssertEqual(t, result.Source, then.expectedSource, "unexpected result source")
		})
	}
}
