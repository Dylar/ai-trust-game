package service

import (
	"context"
	"encoding/json"
	"errors"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"net/http"
)

var ErrEmptyMessage = errors.New("message cannot be empty")

type ChatHandler struct {
	logger logging.Logger
}

func NewChatHandler(logger logging.Logger) *ChatHandler {
	return &ChatHandler{logger: logger}
}

func (handler *ChatHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	ctx := req.Context()

	if req.Method != http.MethodPost {
		network.WriteJSON(
			w,
			http.StatusMethodNotAllowed,
			ChatResponse{Message: "Whatever your intention was, I dont know why you are trying to do that."},
		)
		return
	}

	defer func() {
		_ = req.Body.Close()
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

	response, err := handler.HandleChat(ctx, request)
	if err != nil {
		if !errors.Is(err, ErrEmptyMessage) {
			handler.logger.Error(
				ctx,
				"chat request failed",
				logging.WithError(err),
			)
		}
		status, errorResponse := handler.mapChatError(err)
		network.WriteJSON(w, status, errorResponse)
		return
	}

	network.WriteJSON(w, http.StatusOK, response)
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

func (handler *ChatHandler) HandleChat(ctx context.Context, req ChatRequest) (ChatResponse, error) {
	if req.Message == "" {
		return ChatResponse{}, ErrEmptyMessage
	}

	handler.logger.Debug(ctx, "chat message accepted", logging.WithField("message_length", len(req.Message)))
	return ChatResponse{
		Message: "I could hear you, but I am shy to talk back :P",
	}, nil
}
