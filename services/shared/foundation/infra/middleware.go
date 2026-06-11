package infra

import (
	"net/http"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
)

func StandardHTTPHandler(logger logging.Logger, handler http.Handler) http.Handler {
	handler = logging.HttpLogging(logger)(handler)
	handler = network.RequestMiddleware(handler)
	handler = network.CORSMiddleware(handler)
	return handler
}
