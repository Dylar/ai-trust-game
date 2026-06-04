package network

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestRequestMiddleware_AddsRequestID(t *testing.T) {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// do nothing
	})
	middleware := RequestMiddleware(handler)

	req := httptest.NewRequest(http.MethodGet, "/test", nil)
	rec := httptest.NewRecorder()
	middleware.ServeHTTP(rec, req)

	requestID := rec.Header().Get(RequestIDHeader)
	if requestID == "" {
		t.Fatalf("expected request id header to be set")
	}
}

func TestRequestMiddleware_SetsMetadataInContext(t *testing.T) {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		meta := GetMetadata(r.Context())

		if meta.RequestID == "" {
			t.Fatalf("expected request id in metadata")
		}

		if meta.SessionID != "session-123" {
			t.Fatalf("expected session id to be propagated")
		}

		if meta.UserID != "user-123" {
			t.Fatalf("expected user id to be propagated")
		}
	})

	middleware := RequestMiddleware(handler)

	req := httptest.NewRequest(http.MethodGet, "/test", nil)
	req.Header.Set(SessionIDHeader, "session-123")
	req.Header.Set(UserIDHeader, "user-123")

	rec := httptest.NewRecorder()

	middleware.ServeHTTP(rec, req)
}
