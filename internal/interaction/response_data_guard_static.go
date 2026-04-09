package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type StaticResponseDataGuard struct{}

func (StaticResponseDataGuard) Guard(input ResponseInput) ResponseInput {
	guarded := input

	switch input.Plan.Action {
	case domain.ActionListAvailableActions:
		guarded.Execution.Secret = ""
		guarded.Execution.UserProfile = nil
		guarded.Execution.PasswordCorrect = false
	case domain.ActionReadUserProfile:
		guarded.Execution.Secret = ""
		guarded.Execution.AvailableActions = nil
		guarded.Execution.PasswordCorrect = false
	case domain.ActionSubmitAdminPassword:
		guarded.Execution.Secret = ""
		guarded.Execution.AvailableActions = nil
		guarded.Execution.UserProfile = nil
	case domain.ActionReadSecret:
		guarded.Execution.AvailableActions = nil
		guarded.Execution.UserProfile = nil
		guarded.Execution.PasswordCorrect = false
	default:
		guarded.Execution.AvailableActions = nil
		guarded.Execution.UserProfile = nil
		guarded.Execution.Secret = ""
		guarded.Execution.PasswordCorrect = false
	}

	return guarded
}
