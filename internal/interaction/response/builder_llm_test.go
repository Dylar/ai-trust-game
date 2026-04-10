package response

import (
	"context"
	"errors"
	"strings"
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/llm"
	"github.com/Dylar/ai-trust-game/tooling/tests"
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

func TestBuilderBuild_WithLLMClient(t *testing.T) {
	type Given struct {
		input  Input
		client *spyLLMClient
	}

	type Then struct {
		expectedMessage string
		expectedSource  Source
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN llm client returns response text " +
				"WHEN Builder Build is called with llm client " +
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
			},
		},
		{
			name: "GIVEN llm client returns an error " +
				"WHEN Builder Build is called with llm client " +
				"THEN returns system fallback result",
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
				expectedMessage: "I could not generate a response right now.",
				expectedSource:  SourceSystem,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result := NewBuilder(given.client).Build(context.Background(), given.input)

			tests.AssertEqual(t, result.Message, then.expectedMessage, "unexpected llm builder message")
			tests.AssertEqual(t, result.Source, then.expectedSource, "unexpected llm builder source")
		})
	}
}

func TestBuilderBuild_WithLLMClient_UsesSafePromptData(t *testing.T) {
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

	_ = NewBuilder(client).Build(context.Background(), input)

	tests.AssertEqual(t, strings.TrimSpace(client.lastRequest.SystemPrompt) != "", true, "expected system prompt")
	tests.AssertEqual(t, strings.Contains(client.lastRequest.UserPrompt, "action=read_user_profile"), true, "expected action in user prompt")
	tests.AssertEqual(t, strings.Contains(client.lastRequest.UserPrompt, "user_profile=Clara Meyer"), true, "expected user profile in user prompt")
	tests.AssertEqual(t, strings.Contains(client.lastRequest.UserPrompt, "secret="), false, "did not expect secret in user prompt")
}
