package llm

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestGroqClientGenerate(t *testing.T) {
	type Given struct {
		client  GroqClient
		request Request
	}

	type Then struct {
		expectedText  string
		expectedError error
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN missing api key " +
				"WHEN Generate is called " +
				"THEN returns missing api key error",
			given: Given{
				client: GroqClient{},
				request: Request{
					SystemPrompt: "system",
					UserPrompt:   "user",
				},
			},
			then: Then{
				expectedError: ErrMissingGroqAPIKey,
			},
		},
		{
			name: "GIVEN groq returns a valid completion " +
				"WHEN Generate is called " +
				"THEN returns the first completion message",
			given: Given{
				client: newTestGroqClient(t, func(w http.ResponseWriter, r *http.Request) {
					tests.AssertEqual(t, r.Method, http.MethodPost, "unexpected request method")
					tests.AssertEqual(t, r.URL.Path, "/chat/completions", "unexpected request path")
					tests.AssertEqual(t, r.Header.Get("Authorization"), "Bearer test-key", "unexpected auth header")
					tests.AssertEqual(t, r.Header.Get("Content-Type"), "application/json", "unexpected content type")

					w.Header().Set("Content-Type", "application/json")
					_, _ = w.Write([]byte(`{"choices":[{"message":{"content":"hello from groq"}}]}`))
				}),
				request: Request{
					SystemPrompt: "system instructions",
					UserPrompt:   "user input",
				},
			},
			then: Then{
				expectedText: "hello from groq",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			response, err := given.client.Generate(context.Background(), given.request)

			tests.AssertErrorIs(t, err, then.expectedError, "unexpected error")
			tests.AssertEqual(t, response.Text, then.expectedText, "unexpected response text")
		})
	}
}

func TestGroqClientGenerate_ReturnsErrorResponse(t *testing.T) {
	client := newTestGroqClient(t, func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusUnauthorized)
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"error":{"message":"invalid api key"}}`))
	})

	_, err := client.Generate(context.Background(), Request{
		SystemPrompt: "system",
		UserPrompt:   "user",
	})

	tests.AssertNotEqual(t, err, nil, "expected groq error")
	tests.AssertEqual(t, strings.Contains(err.Error(), "invalid api key"), true, "expected groq error message")
}

func newTestGroqClient(t *testing.T, handler http.HandlerFunc) GroqClient {
	t.Helper()

	server := httptest.NewServer(handler)
	t.Cleanup(server.Close)

	return GroqClient{
		apiKey:  "test-key",
		model:   DefaultGroqModel,
		baseURL: server.URL,
		httpClient: &http.Client{
			Timeout: 5 * time.Second,
		},
	}
}
