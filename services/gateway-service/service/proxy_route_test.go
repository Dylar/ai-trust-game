package service

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

type receivedRequest struct {
	Method    string
	Path      string
	Query     string
	Body      string
	RequestID string
	SessionID string
	UserID    string
	Proto     string
}

func TestProxyRoutes(t *testing.T) {
	received := make(chan receivedRequest, 1)
	upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		body, err := io.ReadAll(req.Body)
		if err != nil {
			t.Fatalf("failed to read upstream request body: %v", err)
		}

		received <- receivedRequest{
			Method:    req.Method,
			Path:      req.URL.Path,
			Query:     req.URL.RawQuery,
			Body:      string(body),
			RequestID: req.Header.Get(network.RequestIDHeader),
			SessionID: req.Header.Get(network.SessionIDHeader),
			UserID:    req.Header.Get(network.UserIDHeader),
			Proto:     req.Header.Get("X-Forwarded-Proto"),
		}

		network.WriteJSON(w, http.StatusCreated, map[string]string{"status": "proxied"})
	}))
	defer upstream.Close()

	mux := http.NewServeMux()
	logger := logging.NewNoopLogger()
	SetupRoutes(mux, logger, NewHealthHandler(), newTestProxyHandler(t, upstream.URL))

	rec := tests.ExecuteRequest(
		mux,
		http.MethodPost,
		"/session/start?debug=true",
		map[string]string{
			network.SessionIDHeader: "session-123",
			network.UserIDHeader:    "user-456",
			"Content-Type":          "application/json",
		},
		`{"role":"guest"}`,
	)

	assert.Equal(t, rec.Code, http.StatusCreated, "unexpected proxy response status")

	var response map[string]string
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatalf("failed to unmarshal proxy response body: %v", err)
	}
	assert.Equal(t, response["status"], "proxied", "unexpected proxy response body")

	upstreamRequest := receiveUpstreamRequest(t, received)
	assert.Equal(t, upstreamRequest.Method, http.MethodPost, "unexpected upstream method")
	assert.Equal(t, upstreamRequest.Path, "/session/start", "unexpected upstream path")
	assert.Equal(t, upstreamRequest.Query, "debug=true", "unexpected upstream query")
	assert.Equal(t, upstreamRequest.Body, `{"role":"guest"}`, "unexpected upstream body")
	assert.Equal(t, upstreamRequest.SessionID, "session-123", "unexpected upstream session id")
	assert.Equal(t, upstreamRequest.UserID, "user-456", "unexpected upstream user id")
	assert.Equal(t, upstreamRequest.Proto, "http", "unexpected forwarded proto")
	if upstreamRequest.RequestID == "" {
		t.Fatal("expected upstream request id")
	}
	assert.Equal(t, rec.Header().Get(network.RequestIDHeader), upstreamRequest.RequestID, "response and upstream request id should match")
}

func receiveUpstreamRequest(t *testing.T, received <-chan receivedRequest) receivedRequest {
	t.Helper()

	select {
	case upstreamRequest := <-received:
		return upstreamRequest
	case <-time.After(time.Second):
		t.Fatal("expected gateway to forward the request upstream")
		return receivedRequest{}
	}
}

func TestProxyRouteUnknownPath(t *testing.T) {
	mux := http.NewServeMux()
	logger := logging.NewNoopLogger()
	SetupRoutes(mux, logger, NewHealthHandler(), newTestProxyHandler(t, "http://127.0.0.1:1"))

	rec := tests.ExecuteRequest(
		mux,
		http.MethodGet,
		"/unknown",
		nil,
		"",
	)

	assert.Equal(t, rec.Code, http.StatusNotFound, "unexpected status for unknown route")
}
