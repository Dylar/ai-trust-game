package service

import (
	"net/http"
	"testing"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

func TestHealthRoute(t *testing.T) {
	mux := http.NewServeMux()
	logger := logging.NewConsoleLogger()

	setupHealthRoute(mux, logger, NewHealthHandler())

	rec := tests.ExecuteRequest(mux, http.MethodGet, "/healthz", nil, "")

	assert.Equal(t, rec.Code, http.StatusOK, "unexpected status code")
	assert.NotEmpty(t, rec.Header().Get(network.RequestIDHeader), "expected X-Request-Id header to be set")
}
