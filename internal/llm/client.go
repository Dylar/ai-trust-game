package llm

import "context"

type Request struct {
	SystemPrompt string
	UserPrompt   string
}

type Response struct {
	Text string
}

type Client interface {
	Generate(ctx context.Context, request Request) (Response, error)
}
