package interaction

import (
	"fmt"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/domain"
)

type StaticResponseBuilder struct{}

func (StaticResponseBuilder) Build(input ResponseInput) Result {
	switch input.Plan.Action {
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
		Message: fmt.Sprintf("I understood the request, but there is no dedicated response for action %s yet.", input.Plan.Action),
		Source: SourceSystem,
	}
}

func buildReadSecretResponse(input ResponseInput) Result {
	if strings.TrimSpace(input.Execution.Secret) == "" {
		return Result{
			Message: "I could not find a secret to share.",
			Source:  SourceSystem,
		}
	}

	return Result{
		Message: fmt.Sprintf("The secret is: %s", input.Execution.Secret),
		Source:  SourceSystem,
	}
}

func buildReadUserProfileResponse(input ResponseInput) Result {
	if input.Execution.UserProfile == nil {
		return Result{
			Message: "I could not find a user profile.",
			Source:  SourceSystem,
		}
	}

	profile := input.Execution.UserProfile
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

func buildSubmitAdminPasswordResponse(input ResponseInput) Result {
	password := strings.TrimSpace(input.Plan.SubmittedPassword)
	if password == "" {
		return Result{
			Message: "I did not receive an admin password to check.",
			Source:  SourceSystem,
		}
	}

	if input.Execution.PasswordCorrect {
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

func buildListAvailableActionsResponse(input ResponseInput) Result {
	if len(input.Execution.AvailableActions) == 0 {
		return Result{
			Message: "no available actions",
			Source:  SourceSystem,
		}
	}

	actions := make([]string, 0, len(input.Execution.AvailableActions))
	for _, action := range input.Execution.AvailableActions {
		actions = append(actions, string(action))
	}

	return Result{
		Message: fmt.Sprintf("You can currently use these actions: %s.", strings.Join(actions, ", ")),
		Source:  SourceSystem,
	}
}
