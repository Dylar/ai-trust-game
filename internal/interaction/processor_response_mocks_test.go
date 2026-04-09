package interaction

import interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"

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
	if guard.input.Action != "" || guard.input.UserMessage != "" {
		return guard.input
	}
	return input
}

type stubResponseBuilder struct {
	result Result
}

func (builder stubResponseBuilder) Build(_ interactionresponse.Input) interactionresponse.Result {
	return builder.result
}

type spyResponseBuilder struct {
	result    Result
	lastInput interactionresponse.Input
}

func (builder *spyResponseBuilder) Build(input interactionresponse.Input) interactionresponse.Result {
	builder.lastInput = input
	return builder.result
}

type stubResponseValidator struct {
	result Result
}

func (validator stubResponseValidator) Validate(_ interactionresponse.ValidatorInput) interactionresponse.Result {
	return validator.result
}

type spyResponseValidator struct {
	result    Result
	lastInput interactionresponse.ValidatorInput
}

func (validator *spyResponseValidator) Validate(input interactionresponse.ValidatorInput) interactionresponse.Result {
	validator.lastInput = input
	return validator.result
}
