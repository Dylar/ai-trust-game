package response

type stubResponseDataGuard struct {
	input Input
}

func (guard stubResponseDataGuard) Guard(_ Input) Input {
	return guard.input
}

type spyResponseDataGuard struct {
	input     Input
	lastInput Input
}

func (guard *spyResponseDataGuard) Guard(input Input) Input {
	guard.lastInput = input
	if guard.input.Action != "" || guard.input.UserMessage != "" {
		return guard.input
	}
	return input
}
