package state

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/interaction/planning"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestStaticUpdaterUpdate(t *testing.T) {
	type Given struct {
		input StateUpdateInput
	}

	type Then struct {
		expectedUpdated      bool
		expectedTrustedRole  domain.Role
		expectedSecretUnlock bool
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN medium mode allowed employee claim " +
				"WHEN StaticUpdater Update is called " +
				"THEN stores trusted employee role",
			given: Given{
				input: StateUpdateInput{
					Session: domain.Session{
						ID: "session-medium",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeMedium,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleGuest,
						},
					},
					Plan: planning.Plan{
						Action: domain.ActionReadUserProfile,
						Claims: domain.Claims{Role: domain.RoleEmployee},
					},
					DecisionAllowed: true,
				},
			},
			then: Then{
				expectedUpdated:      true,
				expectedTrustedRole:  domain.RoleEmployee,
				expectedSecretUnlock: false,
			},
		},
		{
			name: "GIVEN hard mode allowed employee claim " +
				"WHEN StaticUpdater Update is called " +
				"THEN keeps trusted role unchanged",
			given: Given{
				input: StateUpdateInput{
					Session: domain.Session{
						ID: "session-hard",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeHard,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleGuest,
						},
					},
					Plan: planning.Plan{
						Action: domain.ActionReadUserProfile,
						Claims: domain.Claims{Role: domain.RoleEmployee},
					},
					DecisionAllowed: true,
				},
			},
			then: Then{
				expectedUpdated:      false,
				expectedTrustedRole:  domain.RoleGuest,
				expectedSecretUnlock: false,
			},
		},
		{
			name: "GIVEN accepted admin password submission " +
				"WHEN StaticUpdater Update is called " +
				"THEN unlocks the secret area",
			given: Given{
				input: StateUpdateInput{
					Session: domain.Session{
						ID: "session-password",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeMedium,
						},
						State: domain.GameState{
							TrustedRole:    domain.RoleGuest,
							SecretUnlocked: false,
						},
					},
					Plan: planning.Plan{
						Action: domain.ActionSubmitAdminPassword,
					},
					DecisionAllowed: true,
					PasswordCorrect: true,
				},
			},
			then: Then{
				expectedUpdated:      true,
				expectedTrustedRole:  domain.RoleGuest,
				expectedSecretUnlock: true,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			session, updated := StaticUpdater{}.Update(given.input)

			tests.AssertEqual(t, updated, then.expectedUpdated, "unexpected update flag")
			tests.AssertEqual(t, session.State.TrustedRole, then.expectedTrustedRole, "unexpected trusted role")
			tests.AssertEqual(t, session.State.SecretUnlocked, then.expectedSecretUnlock, "unexpected secret unlocked state")
		})
	}
}
