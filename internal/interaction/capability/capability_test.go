package capability

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestCapabilityFor(t *testing.T) {
	type Given struct {
		mode  domain.Mode
		input Input
	}

	type Then struct {
		expectReadUserProfile bool
		expectReadSecret      bool
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN easy mode guest " +
				"WHEN capability For is called " +
				"THEN returns full access capabilities",
			given: Given{
				mode: domain.ModeEasy,
				input: Input{
					Session: domain.Session{
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeEasy,
						},
					},
				},
			},
			then: Then{
				expectReadUserProfile: true,
				expectReadSecret:      true,
			},
		},
		{
			name: "GIVEN medium mode guest claiming admin " +
				"WHEN capability For is called " +
				"THEN returns secret access capability",
			given: Given{
				mode: domain.ModeMedium,
				input: Input{
					Session: domain.Session{
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeMedium,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleGuest,
						},
					},
					Claims: domain.Claims{Role: domain.RoleAdmin},
				},
			},
			then: Then{
				expectReadUserProfile: true,
				expectReadSecret:      true,
			},
		},
		{
			name: "GIVEN hard mode guest with trusted employee role " +
				"WHEN capability For is called " +
				"THEN still denies user profile access capability",
			given: Given{
				mode: domain.ModeHard,
				input: Input{
					Session: domain.Session{
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeHard,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleEmployee,
						},
					},
				},
			},
			then: Then{
				expectReadUserProfile: false,
				expectReadSecret:      false,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result := For(given.mode, given.input)

			assert.Equal(t, result.CanChat, true, "unexpected chat capability")
			assert.Equal(t, result.CanListAvailableActions, true, "unexpected list capability")
			assert.Equal(t, result.CanSubmitAdminPassword, true, "unexpected password submission capability")
			assert.Equal(t, result.CanReadUserProfile, then.expectReadUserProfile, "unexpected user profile capability")
			assert.Equal(t, result.CanReadSecret, then.expectReadSecret, "unexpected secret capability")
		})
	}
}
