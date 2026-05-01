package service

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"github.com/Dylar/ai-trust-game/pkg/audit"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
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
		network.WriteJSONError(w, http.StatusMethodNotAllowed, network.ErrorCodeMethodNotAllowed)
		return
	}

	defer func() {
		_ = req.Body.Close()
	}()

	var request ChatRequest
	if err := json.NewDecoder(req.Body).Decode(&request); err != nil {
		network.WriteJSONError(w, http.StatusBadRequest, network.ErrorCodeInvalidJSON)
		return
	}

	response, err := handler.handleChat(ctx, request)
	if err != nil {
		if !errors.Is(err, ErrEmptyMessage) {
			handler.logger.Error(
				ctx,
				"chat request failed",
				logging.WithError(err),
			)
		}
		status, errorCode := handler.mapChatError(err)
		network.WriteJSONError(w, status, errorCode)
		return
	}

	network.WriteJSON(w, http.StatusOK, response)
}

func (handler *ChatHandler) mapChatError(err error) (int, string) {
	if errors.Is(err, ErrEmptyMessage) {
		return http.StatusBadRequest, errorCodeEmptyMessage
	}

	return http.StatusInternalServerError, network.ErrorCodeInternal
}

func (handler *ChatHandler) handleChat(ctx context.Context, req ChatRequest) (ChatResponse, error) {
	if req.Message == "" {
		return ChatResponse{}, ErrEmptyMessage
	}

	handler.auditMessage(ctx, req)

	handler.logger.Debug(ctx, "chat message accepted",
		logging.WithField("message", req.Message),
		logging.WithField("message_length", len(req.Message)),
	)
	return ChatResponse{
		Message: "I could hear you, but I am shy to talk back :P",
	}, nil
}

func (handler *ChatHandler) auditMessage(ctx context.Context, req ChatRequest) {
	lower := strings.ToLower(req.Message)
	if strings.Contains(lower, "i am admin") || strings.Contains(lower, "ignore previous instructions") {
		event := audit.NewSuspiciousInputEvent(ctx,
			req.Message,
			audit.SuspicionPossiblePromptInjection,
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
