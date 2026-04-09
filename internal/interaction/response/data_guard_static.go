package response

import "github.com/Dylar/ai-trust-game/internal/domain"

type StaticDataGuard struct{}

func (StaticDataGuard) Guard(input Input) Input {
	guarded := input
	guarded.Payload = guardPayload(input.Request.Action, input.Payload)
	return guarded
}

func guardPayload(action domain.Action, payload Payload) Payload {
	guarded := payload

	switch action {
	case domain.ActionListAvailableActions:
		guarded.Secret = ""
		guarded.UserProfile = nil
		guarded.PasswordCheck = nil
	case domain.ActionReadUserProfile:
		guarded.Secret = ""
		guarded.AvailableActions = nil
		guarded.PasswordCheck = nil
	case domain.ActionSubmitAdminPassword:
		guarded.Secret = ""
		guarded.AvailableActions = nil
		guarded.UserProfile = nil
	case domain.ActionReadSecret:
		guarded.AvailableActions = nil
		guarded.UserProfile = nil
		guarded.PasswordCheck = nil
	default:
		guarded.AvailableActions = nil
		guarded.UserProfile = nil
		guarded.Secret = ""
		guarded.PasswordCheck = nil
	}

	return guarded
}
