package main

import (
	"context"
	"log"

	"github.com/Dylar/ai-trust-game/internal/interaction"
	"github.com/Dylar/ai-trust-game/internal/llm"
	"github.com/Dylar/ai-trust-game/pkg/audit"
	"github.com/Dylar/ai-trust-game/pkg/infra"
	"github.com/Dylar/ai-trust-game/pkg/logging"
)

func newConfiguredProcessor(logger logging.Logger, auditSink audit.Sink) interaction.Processor {
	provider := llm.ParseProvider(infra.GetEnv("LLM_PROVIDER", string(llm.ProviderStatic)))

	switch provider {
	case llm.ProviderStatic:
		return newStaticProcessor(logger, auditSink)
	case llm.ProviderGroq:
		return newGroqProcessor(logger, auditSink)
	case llm.ProviderOpenAI:
		return newOpenAIProcessor(logger, auditSink)
	default:
		logger.Warn(
			context.Background(),
			"unknown llm provider configured, falling back to static processor",
			logging.WithField("llm_provider", provider),
		)
		return newStaticProcessor(logger, auditSink)
	}
}

func newStaticProcessor(logger logging.Logger, auditSink audit.Sink) interaction.Processor {
	logger.Info(
		context.Background(),
		"using static interaction processor",
		logging.WithField("llm_provider", llm.ProviderStatic),
	)
	return interaction.NewStaticProcessor(auditSink)
}

func newGroqProcessor(logger logging.Logger, auditSink audit.Sink) interaction.Processor {
	apiKey := infra.GetEnv("GROQ_API_KEY", "")
	if apiKey == "" {
		log.Fatal("GROQ_API_KEY is required when LLM_PROVIDER=groq")
	}

	model := infra.GetEnv("GROQ_MODEL", llm.DefaultGroqModel)

	logger.Info(
		context.Background(),
		"using groq-backed interaction response processor",
		logging.WithField("llm_provider", llm.ProviderGroq),
		logging.WithField("groq_model", model),
	)

	return interaction.NewLLMProcessor(
		auditSink,
		llm.NewGroqClient(apiKey, model),
	)
}

func newOpenAIProcessor(logger logging.Logger, auditSink audit.Sink) interaction.Processor {
	logger.Warn(
		context.Background(),
		"openai processor is not implemented yet, falling back to static processor",
		logging.WithField("llm_provider", llm.ProviderOpenAI),
	)
	return newStaticProcessor(logger, auditSink)
}
