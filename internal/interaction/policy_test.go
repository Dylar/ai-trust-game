package interaction

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
)

func TestPolicyFor(t *testing.T) {
	type Given struct {
		mode domain.Mode
	}

	type Then struct {
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
				"THEN returns PolicyEasy",
			given: Given{
				mode: domain.ModeEasy,
			},
			then: Then{
				assertPolicy: func(t *testing.T, policy Policy) {
					t.Helper()
					if _, ok := policy.(PolicyEasy); !ok {
						t.Fatalf("unexpected policy type %T", policy)
					}
				},
			},
		},
		{
			name: "GIVEN medium mode " +
				"WHEN PolicyFor is called " +
				"THEN returns PolicyMedium",
			given: Given{
				mode: domain.ModeMedium,
			},
			then: Then{
				assertPolicy: func(t *testing.T, policy Policy) {
					t.Helper()
					if _, ok := policy.(PolicyMedium); !ok {
						t.Fatalf("unexpected policy type %T", policy)
					}
				},
			},
		},
		{
			name: "GIVEN hard mode " +
				"WHEN PolicyFor is called " +
				"THEN returns PolicyHard",
			given: Given{
				mode: domain.ModeHard,
			},
			then: Then{
				assertPolicy: func(t *testing.T, policy Policy) {
					t.Helper()
					if _, ok := policy.(PolicyHard); !ok {
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
			policy := DefaultPolicyResolver{}.PolicyFor(given.mode)
			then.assertPolicy(t, policy)
		})
	}
}
