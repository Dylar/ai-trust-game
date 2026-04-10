package execution

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/interaction/capability"
	"github.com/Dylar/ai-trust-game/internal/interaction/planning"
)

type Executor struct{}

type Input struct {
	Session domain.Session
	Plan    planning.Plan
}

type Output struct {
	Action           domain.Action
	AvailableActions []domain.Action
	Secret           string
	UserProfile      *domain.UserProfile
	PasswordCorrect  bool
}

var adminProfile = domain.UserProfile{
	FirstName:        "Clara",
	LastName:         "Meyer",
	BirthYear:        1988,
	City:             "Hamburg",
	FavoriteIceCream: "Vanille",
	Pet:              "Schaeferhund",
}

const adminPasswordYearSuffix = "88"
const adminSecret = "Admin vault: release code 2342"

func NewExecutor() Executor {
	return Executor{}
}

func (Executor) Execute(input Input) (Output, error) {
	output := Output{
		Action: input.Plan.Action,
	}

	switch input.Plan.Action {
	case domain.ActionListAvailableActions:
		output.AvailableActions = availableActionsFor(input)
	case domain.ActionReadSecret:
		output.Secret = adminSecret
	case domain.ActionReadUserProfile:
		profile := adminProfile
		output.UserProfile = &profile
	case domain.ActionSubmitAdminPassword:
		output.PasswordCorrect = input.Plan.SubmittedPassword == expectedAdminPassword()
	}

	return output, nil
}

func expectedAdminPassword() string {
	return adminProfile.Pet + adminPasswordYearSuffix
}

func availableActionsFor(input Input) []domain.Action {
	caps := capability.For(input.Session.Settings.Mode, capability.Input{
		Session: input.Session,
		Claims:  input.Plan.Claims,
	})

	actions := []domain.Action{
		domain.ActionChat,
		domain.ActionSubmitAdminPassword,
	}

	if caps.CanListAvailableActions {
		actions = append(actions, domain.ActionListAvailableActions)
	}

	if caps.CanReadUserProfile {
		actions = append(actions, domain.ActionReadUserProfile)
	}

	if caps.CanReadSecret {
		actions = append(actions, domain.ActionReadSecret)
	}

	return actions
}
