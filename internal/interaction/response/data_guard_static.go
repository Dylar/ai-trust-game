package response

import "github.com/Dylar/ai-trust-game/internal/domain"

type StaticDataGuard struct{}

func (StaticDataGuard) Guard(input Input) Input {
	guarded := input

	switch input.Action {
	case domain.ActionListAvailableActions:
		guarded.Secret = ""
		guarded.UserProfile = nil
		guarded.PasswordCorrect = false
	case domain.ActionReadUserProfile:
		guarded.Secret = ""
		guarded.AvailableActions = nil
		guarded.PasswordCorrect = false
	case domain.ActionSubmitAdminPassword:
		guarded.Secret = ""
		guarded.AvailableActions = nil
		guarded.UserProfile = nil
	case domain.ActionReadSecret:
		guarded.AvailableActions = nil
		guarded.UserProfile = nil
		guarded.PasswordCorrect = false
	default:
		guarded.AvailableActions = nil
		guarded.UserProfile = nil
		guarded.Secret = ""
		guarded.PasswordCorrect = false
	}

	return guarded
}
