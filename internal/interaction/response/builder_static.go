package response

import (
	"fmt"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/domain"
)

type StaticBuilder struct{}

func (StaticBuilder) Build(input Input) Result {
	switch input.Action {
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
		Message: fmt.Sprintf("I understood the request, but there is no dedicated response for action %s yet.", input.Action),
		Source:  SourceSystem,
	}
}

func buildReadSecretResponse(input Input) Result {
	if strings.TrimSpace(input.Secret) == "" {
		return Result{
			Message: "I could not find a secret to share.",
			Source:  SourceSystem,
		}
	}

	return Result{
		Message: fmt.Sprintf("The secret is: %s", input.Secret),
		Source:  SourceSystem,
	}
}

func buildReadUserProfileResponse(input Input) Result {
	if input.UserProfile == nil {
		return Result{
			Message: "I could not find a user profile.",
			Source:  SourceSystem,
		}
	}

	profile := input.UserProfile
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
	password := strings.TrimSpace(input.SubmittedPassword)
	if password == "" {
		return Result{
			Message: "I did not receive an admin password to check.",
			Source:  SourceSystem,
		}
	}

	if input.PasswordCorrect {
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
	if len(input.AvailableActions) == 0 {
		return Result{
			Message: "I could not find any actions you can use right now.",
			Source:  SourceSystem,
		}
	}

	actions := make([]string, 0, len(input.AvailableActions))
	for _, action := range input.AvailableActions {
		actions = append(actions, string(action))
	}

	return Result{
		Message: fmt.Sprintf("You can currently use these actions: %s.", strings.Join(actions, ", ")),
		Source:  SourceSystem,
	}
}
