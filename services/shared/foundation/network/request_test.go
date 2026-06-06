package network

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestRequestMiddleware_AddsRequestID(t *testing.T) {
	type Then struct {
		expectRequestID bool
	}

	type Scenario struct {
		name string
		then Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN request without metadata headers " +
				"WHEN RequestMiddleware handles it " +
				"THEN adds request id response header",
			then: Then{expectRequestID: true},
		},
	}

	for _, scenario := range scenarios {
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				// do nothing
			})
			middleware := RequestMiddleware(handler)

			req := httptest.NewRequest(http.MethodGet, "/test", nil)
			rec := httptest.NewRecorder()
			middleware.ServeHTTP(rec, req)

			requestID := rec.Header().Get(RequestIDHeader)
			if then.expectRequestID && requestID == "" {
				t.Fatalf("expected request id header to be set")
			}
		})
	}
}

func TestRequestMiddleware_SetsMetadataInContext(t *testing.T) {
	type Given struct {
		sessionID string
		userID    string
	}

	type Then struct {
		expectedSessionID string
		expectedUserID    string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN session and user headers " +
				"WHEN RequestMiddleware handles request " +
				"THEN stores metadata in context",
			given: Given{
				sessionID: "session-123",
				userID:    "user-123",
			},
			then: Then{
				expectedSessionID: "session-123",
				expectedUserID:    "user-123",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				meta := GetMetadata(r.Context())

				if meta.RequestID == "" {
					t.Fatalf("expected request id in metadata")
				}

				if meta.SessionID != then.expectedSessionID {
					t.Fatalf("expected session id %q, got %q", then.expectedSessionID, meta.SessionID)
				}

				if meta.UserID != then.expectedUserID {
					t.Fatalf("expected user id %q, got %q", then.expectedUserID, meta.UserID)
				}
			})

			middleware := RequestMiddleware(handler)

			req := httptest.NewRequest(http.MethodGet, "/test", nil)
			req.Header.Set(SessionIDHeader, given.sessionID)
			req.Header.Set(UserIDHeader, given.userID)

			rec := httptest.NewRecorder()

			middleware.ServeHTTP(rec, req)
		})
	}
}
