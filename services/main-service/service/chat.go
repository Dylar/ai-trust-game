package service

import (
	"encoding/json"
	"fmt"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"io"
	"net/http"
)

func handleChat(w http.ResponseWriter, req *http.Request) {
	fmt.Println("DEBUG: Chat endpoint called")
	if req.Method != http.MethodPost {
		network.WriteJSON(w,
			http.StatusMethodNotAllowed,
			ChatResponse{Message: "Whatever your intention was, I dont know why you are trying to do that."},
		)
		return
	}

	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {
			fmt.Println("Error closing request body:", err)
		}
	}(req.Body)

	var request ChatRequest
	err := json.NewDecoder(req.Body).Decode(&request)
	if err != nil {
		network.WriteJSON(w,
			http.StatusBadRequest,
			ChatResponse{Message: "Whatever you said, I dont understand it"},
		)
		return
	}

	if request.Message == "" {
		network.WriteJSON(
			w,
			http.StatusBadRequest,
			ChatResponse{Message: "Are you shy? You didn't say anything :P"},
		)
		return
	}

	fmt.Println("Chat message:", request.Message)
	network.WriteJSON(w,
		http.StatusOK,
		ChatResponse{Message: "I could hear you, but I am shy to talk back :P"},
	)
}
