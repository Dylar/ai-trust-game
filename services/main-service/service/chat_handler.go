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
	handler.logger.Info(
		ctx,
		"chat request received",
	)

	if req.Method != http.MethodPost {
		handler.logger.Warn(
			ctx,
			"invalid HTTP method",
			logging.WithField("method", req.Method),
			logging.WithField("path", req.URL.Path),
		)
		network.WriteJSON(
			w,
			http.StatusMethodNotAllowed,
			ChatResponse{Message: "Whatever your intention was, I dont know why you are trying to do that."},
		)
		return
	}

	defer func() {
		err := req.Body.Close()
		if err != nil {
			handler.logger.Warn(
				ctx,
				"failed to close request body",
				logging.WithError(err),
			)
		}
	}()

	var request ChatRequest
	if err := json.NewDecoder(req.Body).Decode(&request); err != nil {
		handler.logger.Warn(
			ctx,
			"failed to decode chat request",
			logging.WithField("method", req.Method),
			logging.WithField("path", req.URL.Path),
			logging.WithError(err),
		)
		network.WriteJSON(
			w,
			http.StatusBadRequest,
			ChatResponse{Message: "Whatever you said, I dont understand it"},
		)
		return
	}

	response, err := handler.HandleChat(ctx, request)

	if err != nil {
		status, errorResponse := handler.mapChatError(ctx, err)
		network.WriteJSON(w, status, errorResponse)
		return
	}

	network.WriteJSON(w, http.StatusOK, response)
}

func (handler *ChatHandler) mapChatError(ctx context.Context, err error) (int, ChatResponse) {
	if errors.Is(err, ErrEmptyMessage) {
		handler.logger.Warn(
			ctx,
			"empty message received",
		)
		return http.StatusBadRequest, ChatResponse{
			Message: "Are you shy? You didn't say anything :P",
		}
	}

	handler.logger.Error(
		ctx,
		"unexpected error in chat handler",
		logging.WithError(err),
	)
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
