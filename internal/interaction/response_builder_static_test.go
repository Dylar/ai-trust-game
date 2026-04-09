package interaction

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestStaticResponseBuilderBuild(t *testing.T) {
	type Given struct {
		input ResponseInput
	}

	type Then struct {
		expectedMessage string
		expectedSource  Source
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN allowed interaction response input " +
				"WHEN StaticResponseBuilder Build is called " +
				"THEN returns system response",
			given: Given{
				input: ResponseInput{
					Interaction: domain.Interaction{
						Session: domain.Session{
							ID:   "session-response",
							Role: domain.RoleGuest,
							Mode: domain.ModeMedium,
						},
					},
					Plan: Plan{
						Action: domain.ActionReadSecret,
					},
					Decision: Decision{
						Allowed: true,
						Reason:  "allowed by response builder test",
					},
					Execution: ExecutionOutput{
						Action: domain.ActionReadSecret,
						Secret: "secret data prepared",
					},
				},
			},
			then: Then{
				expectedMessage: "Interacting with session session-response, Role: guest, Mode: medium, Action: read_secret, Reason: allowed by response builder test",
				expectedSource:  SourceSystem,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result := StaticResponseBuilder{}.Build(given.input)

			tests.AssertEqual(t, result.Message, then.expectedMessage, "unexpected response message")
			tests.AssertEqual(t, result.Source, then.expectedSource, "unexpected response source")
		})
	}
}
