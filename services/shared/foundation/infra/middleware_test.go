package infra

import (
	"net/http"
	"testing"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

func TestStandardHTTPHandler(t *testing.T) {
	handler := StandardHTTPHandler(
		logging.NewNoopLogger(),
		http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
			meta := network.GetMetadata(req.Context())
			network.WriteJSON(w, http.StatusOK, map[string]string{"requestId": meta.RequestID})
		}),
	)

	rec := tests.ExecuteRequest(handler, http.MethodGet, "/example", nil, "")

	assert.Equal(t, rec.Code, http.StatusOK, "unexpected status code")
	assert.NotEmpty(t, rec.Header().Get(network.RequestIDHeader), "expected request id header")
	assert.Equal(t, rec.Header().Get("Access-Control-Allow-Origin"), "*", "unexpected CORS origin")
}
