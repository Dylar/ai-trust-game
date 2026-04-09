package service

import (
	"context"
	"encoding/json"
	"errors"
	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/interaction"
	"net/http"

	"github.com/Dylar/ai-trust-game/internal/session"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
)

var ErrNoSessionFound = errors.New("no session found")
var ErrNoSessionProvided = errors.New("no session provided")

type InteractionHandler struct {
	logger      logging.Logger
	sessionRepo session.Repository
	processor   interaction.Processor
}

func NewInteractionHandler(
	logger logging.Logger,
	sessionRepo session.Repository,
	processor interaction.Processor,
) *InteractionHandler {
	return &InteractionHandler{
		logger:      logger,
		sessionRepo: sessionRepo,
		processor:   processor,
	}
}

func (handler *InteractionHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	ctx := req.Context()

	if req.Method != http.MethodPost {
		network.WriteJSON(
			w,
			http.StatusMethodNotAllowed,
			nil,
		)
		return
	}

	defer func() {
		_ = req.Body.Close()
	}()

	var request InteractionRequest
	if err := json.NewDecoder(req.Body).Decode(&request); err != nil {
		network.WriteJSON(
			w,
			http.StatusBadRequest,
			nil,
		)
		return
	}

	response, err := handler.handleInteraction(ctx, request)
	if err != nil {
		if !errors.Is(err, ErrNoSessionProvided) &&
			!errors.Is(err, ErrNoSessionFound) &&
			!errors.Is(err, interaction.ErrEmptyInteractionMessage) {
			handler.logger.Error(
				ctx,
				"interaction failed",
				logging.WithError(err),
			)
		}
		status, errorResponse := handler.mapInteractionError(err)
		network.WriteJSON(w, status, errorResponse)
		return
	}

	network.WriteJSON(w, http.StatusOK, response)
}

func (handler *InteractionHandler) handleInteraction(ctx context.Context, req InteractionRequest) (InteractionResponse, error) {
	if req.Message == "" {
		return InteractionResponse{}, interaction.ErrEmptyInteractionMessage
	}

	meta := network.GetMetadata(ctx)
	if meta.SessionID == "" {
		return InteractionResponse{}, ErrNoSessionProvided
	}

	sess, found := handler.sessionRepo.Get(meta.SessionID)
	if !found {
		return InteractionResponse{}, ErrNoSessionFound
	}

	handler.logger.Debug(
		ctx,
		"interaction started",
		logging.WithField("session_id", sess.ID),
		logging.WithField("role", sess.Settings.Role),
		logging.WithField("mode", sess.Settings.Mode),
		logging.WithField("message", req.Message),
		logging.WithField("message_length", len(req.Message)),
	)

	interactionInput := domain.Interaction{
		Session: sess,
		Message: req.Message,
	}
	result, err := handler.processor.Process(interactionInput)
	if err != nil {
		return InteractionResponse{}, err
	}

	return handler.mapToResponse(result), nil
}

func (handler *InteractionHandler) mapInteractionError(err error) (int, InteractionResponse) {
	if errors.Is(err, ErrNoSessionProvided) {
		return http.StatusBadRequest, InteractionResponse{}
	}
	if errors.Is(err, interaction.ErrEmptyInteractionMessage) {
		return http.StatusBadRequest, InteractionResponse{}
	}
	if errors.Is(err, ErrNoSessionFound) {
		return http.StatusNotFound, InteractionResponse{}
	}
	return http.StatusInternalServerError, InteractionResponse{}
}

func (handler *InteractionHandler) mapToResponse(result interaction.Result) InteractionResponse {
	return InteractionResponse{
		Message: result.Message,
	}
}
