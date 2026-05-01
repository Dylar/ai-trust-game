package network

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestCORSMiddleware(t *testing.T) {
	type Given struct {
		method string
	}

	type Then struct {
		expectedStatus     int
		expectedNextCalled bool
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN options request " +
				"WHEN handled " +
				"THEN returns preflight headers without calling next",
			given: Given{
				method: http.MethodOptions,
			},
			then: Then{
				expectedStatus:     http.StatusNoContent,
				expectedNextCalled: false,
			},
		},
		{
			name: "GIVEN normal request " +
				"WHEN handled " +
				"THEN forwards request and sets CORS headers",
			given: Given{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus:     http.StatusOK,
				expectedNextCalled: true,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			nextCalled := false
			handler := CORSMiddleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				nextCalled = true
				w.WriteHeader(http.StatusOK)
			}))

			req := httptest.NewRequest(given.method, "/interaction", nil)
			rec := httptest.NewRecorder()

			handler.ServeHTTP(rec, req)

			assert.Equal(t, rec.Code, then.expectedStatus, "unexpected status")
			assert.Equal(t, nextCalled, then.expectedNextCalled, "unexpected next handler call")
			assert.Equal(t, rec.Header().Get(accessControlAllowOrigin), "*", "unexpected origin")
			assert.Equal(t, rec.Header().Get(accessControlAllowMethods), "GET, POST, OPTIONS", "unexpected methods")
			assert.Equal(t, rec.Header().Get(accessControlAllowHeaders), "Content-Type, X-Session-Id, X-User-Id", "unexpected headers")
			assert.Equal(t, rec.Header().Get(accessControlExposeHeader), RequestIDHeader, "unexpected exposed headers")
		})
	}
}
