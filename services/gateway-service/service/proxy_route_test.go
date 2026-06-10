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
	unexpectedLoggingRequest := make(chan struct{}, 1)
	gameUpstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
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
	defer gameUpstream.Close()

	loggingUpstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		unexpectedLoggingRequest <- struct{}{}
		w.WriteHeader(http.StatusInternalServerError)
	}))
	defer loggingUpstream.Close()

	mux := http.NewServeMux()
	logger := logging.NewNoopLogger()
	SetupRoutes(
		mux,
		logger,
		NewHealthHandler(),
		newTestProxyHandler(t, gameUpstream.URL),
		newTestProxyHandler(t, loggingUpstream.URL),
		newTestProxyHandler(t, gameUpstream.URL),
		newTestProxyHandler(t, gameUpstream.URL),
	)

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
	assertNoRequest(t, unexpectedLoggingRequest, "expected game request to skip logging service")
}

func TestLogProxyRoutesToLoggingService(t *testing.T) {
	received := make(chan receivedRequest, 1)
	unexpectedGameRequest := make(chan struct{}, 1)
	loggingUpstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		body, err := io.ReadAll(req.Body)
		if err != nil {
			t.Fatalf("failed to read upstream request body: %v", err)
		}

		received <- receivedRequest{
			Method: req.Method,
			Path:   req.URL.Path,
			Body:   string(body),
		}

		w.WriteHeader(http.StatusAccepted)
	}))
	defer loggingUpstream.Close()

	gameUpstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		unexpectedGameRequest <- struct{}{}
		w.WriteHeader(http.StatusInternalServerError)
	}))
	defer gameUpstream.Close()

	mux := http.NewServeMux()
	logger := logging.NewNoopLogger()
	SetupRoutes(
		mux,
		logger,
		NewHealthHandler(),
		newTestProxyHandler(t, gameUpstream.URL),
		newTestProxyHandler(t, loggingUpstream.URL),
		newTestProxyHandler(t, loggingUpstream.URL),
		newTestProxyHandler(t, loggingUpstream.URL),
	)

	rec := tests.ExecuteRequest(
		mux,
		http.MethodPost,
		"/logs/client",
		map[string]string{"Content-Type": "application/json"},
		`{"level":"INFO","category":"interaction","message":"message sent"}`,
	)

	assert.Equal(t, rec.Code, http.StatusAccepted, "unexpected proxy response status")

	upstreamRequest := receiveUpstreamRequest(t, received)
	assert.Equal(t, upstreamRequest.Method, http.MethodPost, "unexpected upstream method")
	assert.Equal(t, upstreamRequest.Path, "/logs/client", "unexpected upstream path")
	assert.Equal(t, upstreamRequest.Body, `{"level":"INFO","category":"interaction","message":"message sent"}`, "unexpected upstream body")
	assertNoRequest(t, unexpectedGameRequest, "expected log request to skip game service")
}

func TestAnalysisProxyRoutesToAuditService(t *testing.T) {
	received := make(chan receivedRequest, 1)
	unexpectedGameRequest := make(chan struct{}, 1)
	auditUpstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		received <- receivedRequest{
			Method: req.Method,
			Path:   req.URL.Path,
			Query:  req.URL.RawQuery,
		}

		network.WriteJSON(w, http.StatusOK, map[string]string{"status": "analysis"})
	}))
	defer auditUpstream.Close()

	gameUpstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		unexpectedGameRequest <- struct{}{}
		w.WriteHeader(http.StatusInternalServerError)
	}))
	defer gameUpstream.Close()

	mux := http.NewServeMux()
	logger := logging.NewNoopLogger()
	SetupRoutes(
		mux,
		logger,
		NewHealthHandler(),
		newTestProxyHandler(t, gameUpstream.URL),
		newTestProxyHandler(t, gameUpstream.URL),
		newTestProxyHandler(t, auditUpstream.URL),
		newTestProxyHandler(t, auditUpstream.URL),
	)

	rec := tests.ExecuteRequest(
		mux,
		http.MethodGet,
		"/analysis/session/session-123?include=summary",
		nil,
		"",
	)

	assert.Equal(t, rec.Code, http.StatusOK, "unexpected proxy response status")

	upstreamRequest := receiveUpstreamRequest(t, received)
	assert.Equal(t, upstreamRequest.Method, http.MethodGet, "unexpected upstream method")
	assert.Equal(t, upstreamRequest.Path, "/analysis/session/session-123", "unexpected upstream path")
	assert.Equal(t, upstreamRequest.Query, "include=summary", "unexpected upstream query")
	assertNoRequest(t, unexpectedGameRequest, "expected analysis request to skip game service")
}

func TestAuthProxyRoutesToAuthService(t *testing.T) {
	received := make(chan receivedRequest, 1)
	unexpectedGameRequest := make(chan struct{}, 1)
	authUpstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
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

		network.WriteJSON(w, http.StatusOK, map[string]string{"status": "auth"})
	}))
	defer authUpstream.Close()

	gameUpstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		unexpectedGameRequest <- struct{}{}
		w.WriteHeader(http.StatusInternalServerError)
	}))
	defer gameUpstream.Close()

	mux := http.NewServeMux()
	logger := logging.NewNoopLogger()
	SetupRoutes(
		mux,
		logger,
		NewHealthHandler(),
		newTestProxyHandler(t, gameUpstream.URL),
		newTestProxyHandler(t, gameUpstream.URL),
		newTestProxyHandler(t, gameUpstream.URL),
		newTestProxyHandler(t, authUpstream.URL),
	)

	rec := tests.ExecuteRequest(
		mux,
		http.MethodPost,
		"/auth/users/select",
		map[string]string{
			network.SessionIDHeader: "session-123",
			network.UserIDHeader:    "user-456",
			"Content-Type":          "application/json",
		},
		`{"userId":"user-456"}`,
	)

	assert.Equal(t, rec.Code, http.StatusOK, "unexpected proxy response status")

	upstreamRequest := receiveUpstreamRequest(t, received)
	assert.Equal(t, upstreamRequest.Method, http.MethodPost, "unexpected upstream method")
	assert.Equal(t, upstreamRequest.Path, "/auth/users/select", "unexpected upstream path")
	assert.Equal(t, upstreamRequest.Body, `{"userId":"user-456"}`, "unexpected upstream body")
	assert.Equal(t, upstreamRequest.SessionID, "session-123", "unexpected upstream session id")
	assert.Equal(t, upstreamRequest.UserID, "user-456", "unexpected upstream user id")
	assert.Equal(t, upstreamRequest.Proto, "http", "unexpected forwarded proto")
	if upstreamRequest.RequestID == "" {
		t.Fatal("expected upstream request id")
	}
	assert.Equal(t, rec.Header().Get(network.RequestIDHeader), upstreamRequest.RequestID, "response and upstream request id should match")
	assertNoRequest(t, unexpectedGameRequest, "expected auth request to skip game service")
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

func assertNoRequest(t *testing.T, received <-chan struct{}, message string) {
	t.Helper()

	select {
	case <-received:
		t.Fatal(message)
	case <-time.After(25 * time.Millisecond):
		return
	}
}

func TestProxyRouteUnknownPath(t *testing.T) {
	mux := http.NewServeMux()
	logger := logging.NewNoopLogger()
	SetupRoutes(
		mux,
		logger,
		NewHealthHandler(),
		newTestProxyHandler(t, "http://127.0.0.1:1"),
		newTestProxyHandler(t, "http://127.0.0.1:1"),
		newTestProxyHandler(t, "http://127.0.0.1:1"),
		newTestProxyHandler(t, "http://127.0.0.1:1"),
	)

	rec := tests.ExecuteRequest(
		mux,
		http.MethodGet,
		"/unknown",
		nil,
		"",
	)

	assert.Equal(t, rec.Code, http.StatusNotFound, "unexpected status for unknown route")
}
