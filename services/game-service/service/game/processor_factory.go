package game

import (
	interactionexecution "github.com/Dylar/ai-trust-game/services/game-service/service/game/execution"
	interactionplanning "github.com/Dylar/ai-trust-game/services/game-service/service/game/planning"
	interactionpolicy "github.com/Dylar/ai-trust-game/services/game-service/service/game/policy"
	interactionresponse "github.com/Dylar/ai-trust-game/services/game-service/service/game/response"
	interactionstate "github.com/Dylar/ai-trust-game/services/game-service/service/game/state"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/project/audit"
	"github.com/Dylar/ai-trust-game/services/shared/project/llm"
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
