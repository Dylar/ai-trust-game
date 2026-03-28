package service

import (
	"fmt"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"net/http"
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
