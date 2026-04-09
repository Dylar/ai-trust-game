package interaction

import "fmt"

type StaticResponseBuilder struct{}

func (StaticResponseBuilder) Build(input ResponseInput) Result {
	return Result{
		Message: fmt.Sprintf(
			"Interacting with session %s, Role: %s, Mode: %s, Action: %s, Reason: %s",
			input.Interaction.Session.ID,
			input.Interaction.Session.Role,
			input.Interaction.Session.Mode,
			input.Plan.Action,
			input.Decision.Reason,
		),
		Source: SourceSystem,
	}
}
