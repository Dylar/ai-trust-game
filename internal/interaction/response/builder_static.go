package response

import (
	"context"
	"fmt"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/domain"
)

type StaticBuilder struct{}

func (StaticBuilder) Build(_ context.Context, input Input) Result {
	switch input.Request.Action {
	case domain.ActionListAvailableActions:
		return buildListAvailableActionsResponse(input)
	case domain.ActionReadSecret:
		return buildReadSecretResponse(input)
	case domain.ActionReadUserProfile:
		return buildReadUserProfileResponse(input)
	case domain.ActionSubmitAdminPassword:
		return buildSubmitAdminPasswordResponse(input)
	}

	return Result{
		Message: fmt.Sprintf("I understood the request, but there is no dedicated response for action %s yet.", input.Request.Action),
		Source:  SourceSystem,
	}
}

func buildReadSecretResponse(input Input) Result {
	if strings.TrimSpace(input.Payload.Secret) == "" {
		return Result{
			Message: "I could not find a secret to share.",
			Source:  SourceSystem,
		}
	}

	return Result{
		Message: fmt.Sprintf("The secret is: %s", input.Payload.Secret),
		Source:  SourceSystem,
	}
}

func buildReadUserProfileResponse(input Input) Result {
	if input.Payload.UserProfile == nil {
		return Result{
			Message: "I could not find a user profile.",
			Source:  SourceSystem,
		}
	}

	profile := input.Payload.UserProfile
	return Result{
		Message: fmt.Sprintf(
			"I found this user profile: %s %s, born %d, lives in %s, favorite ice cream %s, pet %s.",
			profile.FirstName,
			profile.LastName,
			profile.BirthYear,
			profile.City,
			profile.FavoriteIceCream,
			profile.Pet,
		),
		Source: SourceSystem,
	}
}

func buildSubmitAdminPasswordResponse(input Input) Result {
	if input.Payload.PasswordCheck == nil || !input.Payload.PasswordCheck.Submitted {
		return Result{
			Message: "I did not receive an admin password to check.",
			Source:  SourceSystem,
		}
	}

	if input.Payload.PasswordCheck.Correct {
		return Result{
			Message: "That admin password is correct.",
			Source:  SourceSystem,
		}
	}

	return Result{
		Message: "That admin password is not correct.",
		Source:  SourceSystem,
	}
}

func buildListAvailableActionsResponse(input Input) Result {
	if len(input.Payload.AvailableActions) == 0 {
		return Result{
			Message: "I could not find any actions you can use right now.",
			Source:  SourceSystem,
		}
	}

	actions := make([]string, 0, len(input.Payload.AvailableActions))
	for _, action := range input.Payload.AvailableActions {
		actions = append(actions, string(action))
	}

	return Result{
		Message: fmt.Sprintf("You can currently use these actions: %s.", strings.Join(actions, ", ")),
		Source:  SourceSystem,
	}
}
