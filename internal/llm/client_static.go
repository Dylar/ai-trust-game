package llm

import "context"

type StaticClient struct {
	Response     Response
	Err          error
	GenerateFunc func(ctx context.Context, request Request) (Response, error)
}

func (client StaticClient) Generate(ctx context.Context, request Request) (Response, error) {
	if client.GenerateFunc != nil {
		return client.GenerateFunc(ctx, request)
	}
	return client.Response, client.Err
}
