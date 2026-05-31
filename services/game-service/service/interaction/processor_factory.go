package interaction

import (
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/services/game-service/service/audit"
	interactionexecution "github.com/Dylar/ai-trust-game/services/game-service/service/interaction/execution"
	interactionplanning "github.com/Dylar/ai-trust-game/services/game-service/service/interaction/planning"
	interactionpolicy "github.com/Dylar/ai-trust-game/services/game-service/service/interaction/policy"
	interactionresponse "github.com/Dylar/ai-trust-game/services/game-service/service/interaction/response"
	interactionstate "github.com/Dylar/ai-trust-game/services/game-service/service/interaction/state"
	"github.com/Dylar/ai-trust-game/services/game-service/service/llm"
)

func NewStaticProcessor(auditSink audit.Sink, logger logging.Logger) Processor {
	return NewProcessor(
		interactionpolicy.NewResolver(),
		interactionplanning.NewStaticPlanner(),
		interactionexecution.NewExecutor(),
		interactionstate.NewUpdater(),
		interactionresponse.NewDataGuard(),
		interactionresponse.NewStaticBuilder(),
		interactionresponse.NewValidator(),
		auditSink,
		logger,
	)
}

func NewLLMProcessor(auditSink audit.Sink, client llm.Client, logger logging.Logger) Processor {
	return NewProcessor(
		interactionpolicy.NewResolver(),
		interactionplanning.NewPlanner(client),
		interactionexecution.NewExecutor(),
		interactionstate.NewUpdater(),
		interactionresponse.NewDataGuard(),
		interactionresponse.NewLLMBuilder(client),
		interactionresponse.NewValidator(),
		auditSink,
		logger,
	)
}
