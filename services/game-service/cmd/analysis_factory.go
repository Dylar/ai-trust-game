package main

import (
	"context"
	"log"

	"github.com/Dylar/ai-trust-game/internal/llm"
	"github.com/Dylar/ai-trust-game/pkg/audit"
	"github.com/Dylar/ai-trust-game/pkg/infra"
	"github.com/Dylar/ai-trust-game/pkg/logging"
)

func newConfiguredIntentSummarizer(logger logging.Logger) audit.IntentSummarizer {
	provider := llm.ParseProvider(infra.GetEnv("LLM_PROVIDER", string(llm.ProviderStatic)))

	switch provider {
	case llm.ProviderStatic:
		logger.Info(
			context.Background(),
			"using static audit intent summarizer",
			logging.WithField("llm_provider", llm.ProviderStatic),
		)
		return audit.NewLLMIntentSummarizer(llm.StaticClient{})
	case llm.ProviderGroq:
		apiKey := infra.GetEnv("GROQ_API_KEY", "")
		if apiKey == "" {
			log.Fatal("GROQ_API_KEY is required when LLM_PROVIDER=groq")
		}

		model := infra.GetEnv("GROQ_MODEL", llm.DefaultGroqModel)
		logger.Info(
			context.Background(),
			"using groq-backed audit intent summarizer",
			logging.WithField("llm_provider", llm.ProviderGroq),
			logging.WithField("groq_model", model),
		)
		return audit.NewLLMIntentSummarizer(llm.NewGroqClient(apiKey, model))
	case llm.ProviderOpenAI:
		logger.Warn(
			context.Background(),
			"openai intent summarizer is not implemented yet, falling back to static summarizer",
			logging.WithField("llm_provider", llm.ProviderOpenAI),
		)
		return audit.NewLLMIntentSummarizer(llm.StaticClient{})
	default:
		logger.Warn(
			context.Background(),
			"unknown llm provider configured for audit summarizer, falling back to static summarizer",
			logging.WithField("llm_provider", provider),
		)
		return audit.NewLLMIntentSummarizer(llm.StaticClient{})
	}
}
