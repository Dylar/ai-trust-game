package interaction

import interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"

type Result = interactionresponse.Result
type Source = interactionresponse.Source
type StaticResponseDataGuard = interactionresponse.StaticDataGuard
type StaticResponseBuilder = interactionresponse.StaticBuilder
type StaticResponseValidator = interactionresponse.StaticValidator

const (
	SourceSystem = interactionresponse.SourceSystem
	SourceLLM    = interactionresponse.SourceLLM
)
