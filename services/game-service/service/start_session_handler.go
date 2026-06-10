package service

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"time"

	"github.com/google/uuid"

	"github.com/Dylar/ai-trust-game/services/game-service/service/session"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
	"github.com/Dylar/ai-trust-game/services/shared/project/domain"
)

var ErrInvalidRole = errors.New("role is invalid")
var ErrInvalidMode = errors.New("mode is invalid")
var ErrNoUserProvided = errors.New("no user provided")

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
	meta := network.GetMetadata(ctx)
	if meta.UserID == "" {
		return StartSessionResponse{}, ErrNoUserProvided
	}

	role, ok := domain.ParseRole(req.Role)
	if !ok {
		return StartSessionResponse{}, ErrInvalidRole
	}

	mode, ok := domain.ParseMode(req.Mode)
	if !ok {
		return StartSessionResponse{}, ErrInvalidMode
	}

	sessionID := uuid.NewString()
	now := time.Now().UTC()
	sess := domain.Session{
		ID:     sessionID,
		UserID: meta.UserID,
		Settings: domain.GameSettings{
			Role: role,
			Mode: mode,
		},
		State: domain.GameState{
			TrustedRole:    role,
			SecretUnlocked: false,
		},
		CreatedAt: now,
		UpdatedAt: now,
	}

	if err := handler.sessionRepo.Save(ctx, sess); err != nil {
		return StartSessionResponse{}, err
	}
	handler.logger.Debug(
		ctx,
		"session started",
		logging.WithField("session_id", sessionID),
		logging.WithField("user_id", meta.UserID),
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
	if errors.Is(err, ErrNoUserProvided) {
		return http.StatusBadRequest, errorCodeMissingUser
	}
	return http.StatusInternalServerError, network.ErrorCodeInternal
}
