package llm

import "context"

type StaticClient struct {
	Response Response
	Err      error
}

func (client StaticClient) Generate(_ context.Context, _ Request) (Response, error) {
	return client.Response, client.Err
}
