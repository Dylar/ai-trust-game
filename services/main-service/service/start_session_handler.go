package service

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/google/uuid"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/session"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
)

var ErrInvalidRole = errors.New("role is invalid")
var ErrInvalidMode = errors.New("mode is invalid")

type StartSessionHandler struct {
	logger      logging.Logger
	sessionRepo session.Repository
}

func NewStartSessionHandler(
	logger logging.Logger,
	sessionRepo session.Repository,
) *StartSessionHandler {
	return &StartSessionHandler{
		logger:      logger,
		sessionRepo: sessionRepo,
	}
}

func (handler *StartSessionHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	ctx := req.Context()

	if req.Method != http.MethodPost {
		network.WriteJSONError(w, http.StatusMethodNotAllowed, network.ErrorCodeMethodNotAllowed)
		return
	}

	defer func() {
		_ = req.Body.Close()
	}()

	var request StartSessionRequest
	if err := json.NewDecoder(req.Body).Decode(&request); err != nil {
		network.WriteJSONError(w, http.StatusBadRequest, network.ErrorCodeInvalidJSON)
		return
	}

	response, err := handler.handleStartSession(ctx, request)
	if err != nil {
		handler.logger.Error(
			ctx,
			"start session failed",
			logging.WithError(err),
		)
		status, errorCode := handler.mapStartSessionError(err)
		network.WriteJSONError(w, status, errorCode)
		return
	}

	network.WriteJSON(w, http.StatusOK, response)
}

func (handler *StartSessionHandler) handleStartSession(ctx context.Context, req StartSessionRequest) (StartSessionResponse, error) {
	role, ok := domain.ParseRole(req.Role)
	if !ok {
		return StartSessionResponse{}, ErrInvalidRole
	}

	mode, ok := domain.ParseMode(req.Mode)
	if !ok {
		return StartSessionResponse{}, ErrInvalidMode
	}

	sessionID := uuid.NewString()
	sess := domain.Session{
		ID: sessionID,
		Settings: domain.GameSettings{
			Role: role,
			Mode: mode,
		},
		State: domain.GameState{
			TrustedRole:    role,
			SecretUnlocked: false,
		},
	}

	handler.sessionRepo.Save(sess)
	handler.logger.Debug(
		ctx,
		"session started",
		logging.WithField("session_id", sessionID),
		logging.WithField("role", role),
		logging.WithField("mode", mode),
	)

	response := StartSessionResponse{
		SessionID: sessionID,
		Role:      string(role),
		Mode:      string(mode),
	}
	return response, nil
}

func (handler *StartSessionHandler) mapStartSessionError(err error) (int, string) {
	if errors.Is(err, ErrInvalidRole) {
		return http.StatusBadRequest, errorCodeInvalidRole
	}
	if errors.Is(err, ErrInvalidMode) {
		return http.StatusBadRequest, errorCodeInvalidMode
	}
	return http.StatusInternalServerError, network.ErrorCodeInternal
}
