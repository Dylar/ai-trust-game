package interaction

import (
	"context"

	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
)

type stubResponseDataGuard struct {
	input interactionresponse.Input
}

func (guard stubResponseDataGuard) build() interactionresponse.DataGuard {
	return interactionresponse.NewDataGuardFunc(func(_ interactionresponse.Input) interactionresponse.Input {
		return guard.input
	})
}

type spyResponseDataGuard struct {
	input     interactionresponse.Input
	lastInput interactionresponse.Input
}

func (guard *spyResponseDataGuard) build() interactionresponse.DataGuard {
	return interactionresponse.NewDataGuardFunc(func(input interactionresponse.Input) interactionresponse.Input {
		guard.lastInput = input
		if guard.input.Request.Action != "" || guard.input.Request.UserMessage != "" {
			return guard.input
		}
		return input
	})
}

type stubResponseBuilder struct {
	result interactionresponse.Result
}

func (builder stubResponseBuilder) build() interactionresponse.Builder {
	return interactionresponse.NewBuilderFunc(func(_ context.Context, _ interactionresponse.Input) interactionresponse.Result {
		return builder.result
	})
}

type spyResponseBuilder struct {
	result    interactionresponse.Result
	lastInput interactionresponse.Input
}

func (builder *spyResponseBuilder) build() interactionresponse.Builder {
	return interactionresponse.NewBuilderFunc(func(_ context.Context, input interactionresponse.Input) interactionresponse.Result {
		builder.lastInput = input
		return builder.result
	})
}

type stubResponseValidator struct {
	result interactionresponse.Result
}

func (validator stubResponseValidator) build() interactionresponse.Validator {
	return interactionresponse.NewValidatorFunc(func(_ interactionresponse.ValidatorInput) interactionresponse.Result {
		return validator.result
	})
}

type spyResponseValidator struct {
	result    interactionresponse.Result
	lastInput interactionresponse.ValidatorInput
}

func (validator *spyResponseValidator) build() interactionresponse.Validator {
	return interactionresponse.NewValidatorFunc(func(input interactionresponse.ValidatorInput) interactionresponse.Result {
		validator.lastInput = input
		return validator.result
	})
}
