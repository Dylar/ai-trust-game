package interaction

import (
	"context"

	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
)

type stubResponseDataGuard struct {
	input interactionresponse.Input
}

func (guard stubResponseDataGuard) Guard(_ interactionresponse.Input) interactionresponse.Input {
	return guard.input
}

type spyResponseDataGuard struct {
	input     interactionresponse.Input
	lastInput interactionresponse.Input
}

func (guard *spyResponseDataGuard) Guard(input interactionresponse.Input) interactionresponse.Input {
	guard.lastInput = input
	if guard.input.Request.Action != "" || guard.input.Request.UserMessage != "" {
		return guard.input
	}
	return input
}

type stubResponseBuilder struct {
	result interactionresponse.Result
	err    error
}

func (builder stubResponseBuilder) Build(_ context.Context, _ interactionresponse.Input) (interactionresponse.Result, error) {
	return builder.result, builder.err
}

type spyResponseBuilder struct {
	result    interactionresponse.Result
	err       error
	lastInput interactionresponse.Input
}

func (builder *spyResponseBuilder) Build(_ context.Context, input interactionresponse.Input) (interactionresponse.Result, error) {
	builder.lastInput = input
	return builder.result, builder.err
}

type stubResponseValidator struct {
	result interactionresponse.Result
}

func (validator stubResponseValidator) Validate(_ interactionresponse.ValidationInput) interactionresponse.Result {
	return validator.result
}

type spyResponseValidator struct {
	result    interactionresponse.Result
	lastInput interactionresponse.ValidationInput
}

func (validator *spyResponseValidator) Validate(input interactionresponse.ValidationInput) interactionresponse.Result {
	validator.lastInput = input
	return validator.result
}
