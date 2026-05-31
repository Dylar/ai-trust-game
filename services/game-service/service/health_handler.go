package service

import (
	"net/http"

	"github.com/Dylar/ai-trust-game/pkg/network"
)

type HealthResponse struct {
	Status string `json:"status"`
}

type HealthHandler struct{}

func NewHealthHandler() *HealthHandler {
	return &HealthHandler{}
}

func (handler *HealthHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodGet {
		network.WriteJSONError(w, http.StatusMethodNotAllowed, network.ErrorCodeMethodNotAllowed)
		return
	}

	network.WriteJSON(w, http.StatusOK, HealthResponse{Status: "ok"})
}
