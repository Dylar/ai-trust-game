package interaction

import (
	interactionexecution "github.com/Dylar/ai-trust-game/internal/interaction/execution"
	interactionplanning "github.com/Dylar/ai-trust-game/internal/interaction/planning"
	interactionpolicy "github.com/Dylar/ai-trust-game/internal/interaction/policy"
	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
	interactionstate "github.com/Dylar/ai-trust-game/internal/interaction/state"
)

func NewDefaultProcessor() Processor {
	return NewProcessor(
		interactionpolicy.DefaultPolicyResolver{},
		interactionplanning.StaticPlanner{},
		interactionexecution.StaticExecutor{},
		interactionstate.StaticUpdater{},
		interactionresponse.StaticDataGuard{},
		interactionresponse.StaticBuilder{},
		interactionresponse.StaticValidator{},
	)
}
