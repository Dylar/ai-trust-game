package interaction

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	interactionexecution "github.com/Dylar/ai-trust-game/internal/interaction/execution"
	interactionplanning "github.com/Dylar/ai-trust-game/internal/interaction/planning"
	interactionpolicy "github.com/Dylar/ai-trust-game/internal/interaction/policy"
	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
)

func newResponseInput(
	interaction domain.Interaction,
	plan interactionplanning.Plan,
	decision interactionpolicy.Decision,
	execution interactionexecution.ExecutionOutput,
) interactionresponse.Input {
	return interactionresponse.Input{
		Session: interactionresponse.SessionMeta{
			ID:   interaction.Session.ID,
			Role: interaction.Session.Settings.Role,
			Mode: interaction.Session.Settings.Mode,
		},
		Request: interactionresponse.RequestMeta{
			UserMessage:       interaction.Message,
			Action:            plan.Action,
			SubmittedPassword: plan.SubmittedPassword,
			DecisionReason:    decision.Reason,
		},
		Payload: interactionresponse.Payload{
			AvailableActions: execution.AvailableActions,
			Secret:           execution.Secret,
			UserProfile:      execution.UserProfile,
			PasswordCheck: &interactionresponse.PasswordCheck{
				Submitted: plan.SubmittedPassword != "",
				Correct:   execution.PasswordCorrect,
			},
		},
	}
}
