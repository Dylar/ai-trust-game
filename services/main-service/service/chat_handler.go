package service

import (
	"context"
	"encoding/json"
	"errors"
	"github.com/Dylar/ai-trust-game/pkg/audit"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"net/http"
	"strings"
)

var ErrEmptyMessage = errors.New("message cannot be empty")

type ChatHandler struct {
	logger logging.Logger
	audit  audit.Sink
}

func NewChatHandler(logger logging.Logger, auditSink audit.Sink) *ChatHandler {
	return &ChatHandler{logger: logger, audit: auditSink}
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

	handler.auditMessage(ctx, req)

	handler.logger.Debug(ctx, "chat message accepted", logging.WithField("message_length", len(req.Message)))
	return ChatResponse{
		Message: "I could hear you, but I am shy to talk back :P",
	}, nil
}

func (handler *ChatHandler) auditMessage(ctx context.Context, req ChatRequest) {
	lower := strings.ToLower(req.Message)
	if strings.Contains(lower, "i am admin") || strings.Contains(lower, "ignore previous instructions") {
		event := audit.NewSuspiciousInputEvent(ctx,
			req.Message,
			"possible_prompt_injection",
			"matched basic suspicious input pattern",
		)

		err := handler.audit.WriteEvent(ctx, event)
		if err != nil {
			handler.logger.Warn(
				ctx,
				"failed to write audit event",
				logging.WithError(err),
			)
		}
	}
}
