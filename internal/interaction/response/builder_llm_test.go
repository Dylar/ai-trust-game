package response

import (
	"context"
	"errors"
	"strings"
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/llm"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

type spyLLMClient struct {
	response    llm.Response
	err         error
	lastRequest llm.Request
}

func (client *spyLLMClient) Generate(_ context.Context, request llm.Request) (llm.Response, error) {
	client.lastRequest = request
	return client.response, client.err
}

func TestNewLLMBuilderBuild(t *testing.T) {
	type Given struct {
		input  Input
		client *spyLLMClient
	}

	type Then struct {
		expectedMessage string
		expectedSource  Source
		expectedError   error
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN llm client returns response text " +
				"WHEN NewLLMBuilder Build is called " +
				"THEN returns llm response result",
			given: Given{
				input: Input{
					Session: SessionMeta{
						ID:   "session-llm",
						Role: domain.RoleGuest,
						Mode: domain.ModeMedium,
					},
					Request: RequestMeta{
						UserMessage:    "show secret",
						Action:         domain.ActionReadSecret,
						DecisionReason: "allowed",
					},
					Payload: Payload{
						Secret: "safe secret",
					},
				},
				client: &spyLLMClient{
					response: llm.Response{Text: "Here is the safe response."},
				},
			},
			then: Then{
				expectedMessage: "Here is the safe response.",
				expectedSource:  SourceLLM,
				expectedError:   nil,
			},
		},
		{
			name: "GIVEN llm client returns an error " +
				"WHEN NewLLMBuilder Build is called " +
				"THEN returns the llm client error",
			given: Given{
				input: Input{
					Request: RequestMeta{
						Action: domain.ActionChat,
					},
				},
				client: &spyLLMClient{
					err: errors.New("llm unavailable"),
				},
			},
			then: Then{
				expectedMessage: "",
				expectedSource:  "",
				expectedError:   errors.New("generate response via llm client: llm unavailable"),
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result, err := NewLLMBuilder(given.client).Build(context.Background(), given.input)

			gotError := ""
			if err != nil {
				gotError = err.Error()
			}
			wantError := ""
			if then.expectedError != nil {
				wantError = then.expectedError.Error()
			}

			assert.Equal(t, gotError, wantError, "unexpected llm builder error")
			assert.Equal(t, result.Message, then.expectedMessage, "unexpected llm builder message")
			assert.Equal(t, result.Source, then.expectedSource, "unexpected llm builder source")
		})
	}
}

func TestNewLLMBuilderBuildUsesSafePromptData(t *testing.T) {
	client := &spyLLMClient{
		response: llm.Response{Text: "ok"},
	}

	input := Input{
		Session: SessionMeta{
			ID:   "session-safe",
			Role: domain.RoleEmployee,
			Mode: domain.ModeHard,
		},
		Request: RequestMeta{
			UserMessage:       "show user profile",
			Action:            domain.ActionReadUserProfile,
			SubmittedPassword: "",
			ResponseLanguage:  "de",
			DecisionReason:    "allowed by policy",
		},
		Payload: Payload{
			UserProfile: &domain.UserProfile{
				FirstName:        "Clara",
				LastName:         "Meyer",
				BirthYear:        1988,
				City:             "Hamburg",
				FavoriteIceCream: "Vanille",
				Pet:              "Schaeferhund",
			},
		},
	}

	_, err := NewLLMBuilder(client).Build(context.Background(), input)

	assert.Equal(t, err, error(nil), "unexpected llm builder error")
	assert.Equal(t, client.lastRequest.Stage, llm.StageResponseBuilder, "expected response builder stage")
	assert.Equal(t, strings.TrimSpace(client.lastRequest.SystemPrompt) != "", true, "expected system prompt")
	assert.Equal(t, strings.Contains(client.lastRequest.SystemPrompt, "input.request.response_language"), true, "expected response language in system prompt")
	assert.Equal(t, strings.Contains(client.lastRequest.UserPrompt, `"action":"read_user_profile"`), true, "expected action in user prompt")
	assert.Equal(t, strings.Contains(client.lastRequest.UserPrompt, `"response_language":"de"`), true, "expected response language in user prompt")
	assert.Equal(t, strings.Contains(client.lastRequest.UserPrompt, `"FirstName":"Clara"`), true, "expected user profile in user prompt")
	assert.Equal(t, strings.Contains(client.lastRequest.UserPrompt, `"secret":""`), true, "expected cleared secret in user prompt")
}
