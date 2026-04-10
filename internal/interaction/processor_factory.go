package interaction

import (
	interactionexecution "github.com/Dylar/ai-trust-game/internal/interaction/execution"
	interactionplanning "github.com/Dylar/ai-trust-game/internal/interaction/planning"
	interactionpolicy "github.com/Dylar/ai-trust-game/internal/interaction/policy"
	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
	interactionstate "github.com/Dylar/ai-trust-game/internal/interaction/state"
	"github.com/Dylar/ai-trust-game/internal/llm"
	"github.com/Dylar/ai-trust-game/pkg/audit"
	"github.com/Dylar/ai-trust-game/pkg/logging"
)

func NewStaticProcessor(auditSink audit.Sink, logger logging.Logger) Processor {
	return NewProcessor(
		interactionpolicy.NewResolver(),
		interactionplanning.NewStaticPlanner(),
		interactionexecution.NewStaticExecutor(),
		interactionstate.NewStaticUpdater(),
		interactionresponse.NewStaticDataGuard(),
		interactionresponse.NewStaticBuilder(),
		interactionresponse.NewStaticValidator(),
		auditSink,
		logger,
	)
}

func NewLLMProcessor(auditSink audit.Sink, client llm.Client, logger logging.Logger) Processor {
	return NewProcessor(
		interactionpolicy.NewResolver(),
		interactionplanning.NewPlanner(client),
		interactionexecution.NewStaticExecutor(),
		interactionstate.NewStaticUpdater(),
		interactionresponse.NewStaticDataGuard(),
		interactionresponse.NewLLMBuilder(client),
		interactionresponse.NewStaticValidator(),
		auditSink,
		logger,
	)
}
