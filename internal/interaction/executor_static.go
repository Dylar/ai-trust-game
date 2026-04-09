package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type StaticExecutor struct{}

func (StaticExecutor) Execute(input ExecutionInput) (ExecutionOutput, error) {
	output := ExecutionOutput{
		Action: input.Plan.Action,
	}

	switch input.Plan.Action {
	case domain.ActionReadSecret:
		output.Secret = "secret data prepared"
	case domain.ActionGetUserInfo:
		output.UserInfo = "user info prepared"
	}

	return output, nil
}
