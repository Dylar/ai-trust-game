package interaction

type stubResponseDataGuard struct {
	input ResponseInput
}

func (guard stubResponseDataGuard) Guard(_ ResponseInput) ResponseInput {
	return guard.input
}

type spyResponseDataGuard struct {
	input     ResponseInput
	lastInput ResponseInput
}

func (guard *spyResponseDataGuard) Guard(input ResponseInput) ResponseInput {
	guard.lastInput = input
	if guard.input.Plan.Action != "" || guard.input.Interaction.Message != "" || guard.input.Execution.Action != "" {
		return guard.input
	}
	return input
}
