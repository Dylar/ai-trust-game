package llm

import "strings"

type Provider string

const (
	ProviderStatic Provider = "static"
	ProviderGroq   Provider = "groq"
	ProviderOpenAI Provider = "openai"
)

func ParseProvider(value string) Provider {
	switch strings.ToLower(strings.TrimSpace(value)) {
	case "", string(ProviderStatic):
		return ProviderStatic
	case string(ProviderGroq):
		return ProviderGroq
	case string(ProviderOpenAI):
		return ProviderOpenAI
	default:
		return Provider(value)
	}
}
