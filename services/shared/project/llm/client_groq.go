package llm

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"
)

const DefaultGroqBaseURL = "https://api.groq.com/openai/v1"
const DefaultGroqModel = "llama-3.3-70b-versatile"

var ErrMissingGroqAPIKey = errors.New("missing groq api key")

type GroqClient struct {
	apiKey     string
	model      string
	baseURL    string
	httpClient *http.Client
}

func NewGroqClient(apiKey, model string) GroqClient {
	if strings.TrimSpace(model) == "" {
		model = DefaultGroqModel
	}

	return GroqClient{
		apiKey:  apiKey,
		model:   model,
		baseURL: DefaultGroqBaseURL,
		httpClient: &http.Client{
			Timeout: 20 * time.Second,
		},
	}
}

func (client GroqClient) Generate(ctx context.Context, request Request) (Response, error) {
	if strings.TrimSpace(client.apiKey) == "" {
		return Response{}, ErrMissingGroqAPIKey
	}

	httpClient := client.httpClient
	if httpClient == nil {
		httpClient = &http.Client{
			Timeout: 20 * time.Second,
		}
	}

	baseURL := client.baseURL
	if strings.TrimSpace(baseURL) == "" {
		baseURL = DefaultGroqBaseURL
	}

	body, err := json.Marshal(groqChatCompletionRequest{
		Model: client.model,
		Messages: []groqMessage{
			{
				Role:    "system",
				Content: request.SystemPrompt,
			},
			{
				Role:    "user",
				Content: request.UserPrompt,
			},
		},
	})
	if err != nil {
		return Response{}, err
	}

	httpRequest, err := http.NewRequestWithContext(
		ctx,
		http.MethodPost,
		baseURL+"/chat/completions",
		bytes.NewReader(body),
	)
	if err != nil {
		return Response{}, err
	}

	httpRequest.Header.Set("Authorization", "Bearer "+client.apiKey)
	httpRequest.Header.Set("Content-Type", "application/json")

	httpResponse, err := httpClient.Do(httpRequest)
	if err != nil {
		return Response{}, err
	}
	defer func() {
		_ = httpResponse.Body.Close()
	}()

	var response groqChatCompletionResponse
	if err := json.NewDecoder(httpResponse.Body).Decode(&response); err != nil {
		return Response{}, err
	}

	if httpResponse.StatusCode >= http.StatusBadRequest {
		message := strings.TrimSpace(response.Error.Message)
		if message == "" {
			message = "groq request failed"
		}
		return Response{}, fmt.Errorf("groq chat completion failed with status %d: %s", httpResponse.StatusCode, message)
	}

	if len(response.Choices) == 0 {
		return Response{}, nil
	}

	return Response{
		Text: response.Choices[0].Message.Content,
	}, nil
}

type groqChatCompletionRequest struct {
	Model    string        `json:"model"`
	Messages []groqMessage `json:"messages"`
}

type groqMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type groqChatCompletionResponse struct {
	Choices []struct {
		Message groqMessage `json:"message"`
	} `json:"choices"`
	Error struct {
		Message string `json:"message"`
	} `json:"error"`
}
