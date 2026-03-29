package service

import (
	"fmt"
	"net/http"

	"github.com/Dylar/ai-trust-game/pkg/network"
)

type HealthResponse struct {
	Status string `json:"status"`
}

func handleHealth(rspWriter http.ResponseWriter, _ *http.Request) {
	fmt.Println("Health endpoint called")

	response := HealthResponse{
		Status: "ok",
	}

	network.WriteJSON(rspWriter, http.StatusOK, response)
}
