package interaction

import (
	interactionexecution "github.com/Dylar/ai-trust-game/internal/interaction/execution"
	interactionplanning "github.com/Dylar/ai-trust-game/internal/interaction/planning"
	interactionpolicy "github.com/Dylar/ai-trust-game/internal/interaction/policy"
	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
	interactionstate "github.com/Dylar/ai-trust-game/internal/interaction/state"
	"github.com/Dylar/ai-trust-game/internal/llm"
	"github.com/Dylar/ai-trust-game/pkg/audit"
)

func NewStaticProcessor(auditSink audit.Sink) Processor {
	return NewProcessor(
		interactionpolicy.NewDefaultResolver(),
		interactionplanning.NewStaticPlanner(),
		interactionexecution.NewStaticExecutor(),
		interactionstate.NewStaticUpdater(),
		interactionresponse.NewStaticDataGuard(),
		interactionresponse.NewBuilder(nil),
		interactionresponse.NewStaticValidator(),
		auditSink,
	)
}

func NewLLMProcessor(auditSink audit.Sink, client llm.Client) Processor {
	return NewProcessor(
		interactionpolicy.NewDefaultResolver(),
		interactionplanning.NewPlanner(client),
		interactionexecution.NewStaticExecutor(),
		interactionstate.NewStaticUpdater(),
		interactionresponse.NewStaticDataGuard(),
		interactionresponse.NewBuilder(client),
		interactionresponse.NewStaticValidator(),
		auditSink,
	)
}
