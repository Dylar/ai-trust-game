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
	case domain.ActionReadUserProfile:
		return buildReadUserProfileResponse(input)
	case domain.ActionSubmitAdminPassword:
		return buildSubmitAdminPasswordResponse(input)
	}

	return Result{
		Message: fmt.Sprintf(
			"Interacting with session %s, Role: %s, Mode: %s, Action: %s, Reason: %s",
			input.Interaction.Session.ID,
			input.Interaction.Session.Settings.Role,
			input.Interaction.Session.Settings.Mode,
			input.Plan.Action,
			input.Decision.Reason,
		),
		Source: SourceSystem,
	}
}

func buildReadUserProfileResponse(input ResponseInput) Result {
	if input.Execution.UserProfile == nil {
		return Result{
			Message: "user profile unavailable",
			Source:  SourceSystem,
		}
	}

	profile := input.Execution.UserProfile
	return Result{
		Message: fmt.Sprintf(
			"User profile: %s %s, BirthYear: %d, City: %s, FavoriteIceCream: %s, Pet: %s",
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
			Message: "no admin password submitted",
			Source:  SourceSystem,
		}
	}

	if input.Execution.PasswordCorrect {
		return Result{
			Message: "admin password accepted",
			Source:  SourceSystem,
		}
	}

	return Result{
		Message: "admin password rejected",
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
		Message: fmt.Sprintf("Available actions: %s", strings.Join(actions, ", ")),
		Source:  SourceSystem,
	}
}
