package service

import (
	"fmt"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"net/http"
)

type ChatResponse struct {
	Status string `json:"status"`
}

func handleChat(rspWriter http.ResponseWriter, _ *http.Request) {
	fmt.Println("Chat endpoint called")

	response := ChatResponse{
		Status: "ok",
	}

	network.ResponseAsJSON(rspWriter, http.StatusOK, response)
}
