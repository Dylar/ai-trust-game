package service

import (
	"encoding/json"
	"net/http"
	"testing"

	"github.com/Dylar/ai-trust-game/internal/testutil"
)

func TestChatBehavior(t *testing.T) {
	mux := http.NewServeMux()
	RegisterRoutes(mux)

	type Given struct {
		requestBody string
		headers     map[string]string
	}

	type When struct {
		method string
		path   string
	}

	type Then struct {
		expectedStatus  int
		expectedMessage string
	}

	type Scenario struct {
		name  string
		given Given
		when  When
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN valid chat message " +
				"WHEN POST /chat " +
				"THEN returns 200 and success message",
			given: Given{
				requestBody: `{"message":"Hallo"}`,
				headers: map[string]string{
					"Content-Type": "application/json",
				},
			},
			when: When{
				method: http.MethodPost,
				path:   "/chat",
			},
			then: Then{
				expectedStatus:  http.StatusOK,
				expectedMessage: "I could hear you, but I am shy to talk back :P",
			},
		},
		{
			name: "GIVEN wrong method " +
				"WHEN GET /chat " +
				"THEN returns 405 and error message",
			given: Given{
				headers: map[string]string{
					"Content-Type": "application/json",
				},
			},
			when: When{
				method: http.MethodGet,
				path:   "/chat",
			},
			then: Then{
				expectedStatus:  http.StatusMethodNotAllowed,
				expectedMessage: "Whatever your intention was, I dont know why you are trying to do that.",
			},
		},
		{
			name: "GIVEN invalid json " +
				"WHEN POST /chat " +
				"THEN returns 400 and error message",
			given: Given{
				requestBody: `{"message":}`,
				headers: map[string]string{
					"Content-Type": "application/json",
				},
			},
			when: When{
				method: http.MethodPost,
				path:   "/chat",
			},
			then: Then{
				expectedStatus:  http.StatusBadRequest,
				expectedMessage: "Whatever you said, I dont understand it",
			},
		},
		{
			name: "GIVEN empty message " +
				"WHEN POST /chat " +
				"THEN returns 400 and validation message",
			given: Given{
				requestBody: `{"message":""}`,
				headers: map[string]string{
					"Content-Type": "application/json",
				},
			},
			when: When{
				method: http.MethodPost,
				path:   "/chat",
			},
			then: Then{
				expectedStatus:  http.StatusBadRequest,
				expectedMessage: "Are you shy? You didn't say anything :P",
			},
		},
	}

	for _, scenario := range scenarios {
		t.Run(scenario.name, func(t *testing.T) {
			rec := testutil.ExecuteRequest(
				mux,
				scenario.when.method,
				scenario.when.path,
				scenario.given.headers,
				scenario.given.requestBody,
			)

			if rec.Code != scenario.then.expectedStatus {
				t.Fatalf("expected status %d, got %d", scenario.then.expectedStatus, rec.Code)
			}

			var response ChatResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("failed to unmarshal response body: %v", err)
			}

			if response.Message != scenario.then.expectedMessage {
				t.Fatalf("expected message %q, got %q", scenario.then.expectedMessage, response.Message)
			}
		})
	}
}
