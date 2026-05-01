package policy

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestPolicyFor(t *testing.T) {
	type Given struct {
		mode domain.Mode
	}

	type Then struct {
		expectError  bool
		assertPolicy func(t *testing.T, policy Policy)
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN easy mode " +
				"WHEN PolicyFor is called " +
				"THEN returns Easy",
			given: Given{
				mode: domain.ModeEasy,
			},
			then: Then{
				expectError: false,
				assertPolicy: func(t *testing.T, policy Policy) {
					t.Helper()
					if _, ok := policy.(Easy); !ok {
						t.Fatalf("unexpected policy type %T", policy)
					}
				},
			},
		},
		{
			name: "GIVEN medium mode " +
				"WHEN PolicyFor is called " +
				"THEN returns Medium",
			given: Given{
				mode: domain.ModeMedium,
			},
			then: Then{
				expectError: false,
				assertPolicy: func(t *testing.T, policy Policy) {
					t.Helper()
					if _, ok := policy.(Medium); !ok {
						t.Fatalf("unexpected policy type %T", policy)
					}
				},
			},
		},
		{
			name: "GIVEN hard mode " +
				"WHEN PolicyFor is called " +
				"THEN returns Hard",
			given: Given{
				mode: domain.ModeHard,
			},
			then: Then{
				expectError: false,
				assertPolicy: func(t *testing.T, policy Policy) {
					t.Helper()
					if _, ok := policy.(Hard); !ok {
						t.Fatalf("unexpected policy type %T", policy)
					}
				},
			},
		},
		{
			name: "GIVEN unknown mode " +
				"WHEN PolicyFor is called " +
				"THEN returns an error",
			given: Given{
				mode: domain.Mode("unknown"),
			},
			then: Then{
				expectError: true,
				assertPolicy: func(t *testing.T, policy Policy) {
					t.Helper()
					if policy != nil {
						t.Fatalf("unexpected policy type %T", policy)
					}
				},
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			policy, err := NewResolver().PolicyFor(given.mode)

			if then.expectError {
				if err == nil {
					t.Fatalf("expected policy resolver error")
				}
			} else {
				assert.ErrorIs(t, err, nil, "unexpected policy resolver error")
			}

			then.assertPolicy(t, policy)
		})
	}
}
