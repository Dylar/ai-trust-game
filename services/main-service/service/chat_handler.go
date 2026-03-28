package service

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"net/http"
)

type ChatHandler struct{}

func NewChatHandler() *ChatHandler {
	return &ChatHandler{}
}

func (handler *ChatHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodPost {
		network.WriteJSON(
			w,
			http.StatusMethodNotAllowed,
			ChatResponse{Message: "Whatever your intention was, I dont know why you are trying to do that."},
		)
		return
	}

	defer func() {
		if err := req.Body.Close(); err != nil {
			fmt.Println("error closing request body:", err)
		}
	}()

	var request ChatRequest
	if err := json.NewDecoder(req.Body).Decode(&request); err != nil {
		network.WriteJSON(
			w,
			http.StatusBadRequest,
			ChatResponse{Message: "Whatever you said, I dont understand it"},
		)
		return
	}

	response, err := handler.HandleChat(req.Context(), request)

	statusCode := http.StatusOK
	if err != nil {
		status, errorResponse := handler.mapChatError(err)
		network.WriteJSON(w, status, errorResponse)
		return
	}

	network.WriteJSON(w, statusCode, response)
}

func (handler *ChatHandler) mapChatError(err error) (int, ChatResponse) {
	if errors.Is(err, ErrEmptyMessage) {
		return http.StatusBadRequest, ChatResponse{
			Message: "Are you shy? You didn't say anything :P",
		}
	}

	return http.StatusInternalServerError, ChatResponse{
		Message: "Something went wrong",
	}
}

func (handler *ChatHandler) HandleChat(_ context.Context, req ChatRequest) (ChatResponse, error) {
	if req.Message == "" {
		return ChatResponse{}, ErrEmptyMessage
	}

	return ChatResponse{
		Message: "I could hear you, but I am shy to talk back :P",
	}, nil
}
