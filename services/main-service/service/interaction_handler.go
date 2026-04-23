package service

import (
	"context"
	"encoding/json"
	"errors"
	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/interaction"
	interactionplanning "github.com/Dylar/ai-trust-game/internal/interaction/planning"
	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
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
		network.WriteJSONError(w, http.StatusMethodNotAllowed, network.ErrorCodeMethodNotAllowed)
		return
	}

	defer func() {
		_ = req.Body.Close()
	}()

	var request InteractionRequest
	if err := json.NewDecoder(req.Body).Decode(&request); err != nil {
		network.WriteJSONError(w, http.StatusBadRequest, network.ErrorCodeInvalidJSON)
		return
	}

	response, err := handler.handleInteraction(ctx, request)
	if err != nil {
		if !errors.Is(err, ErrNoSessionProvided) &&
			!errors.Is(err, ErrNoSessionFound) &&
			!errors.Is(err, interaction.ErrEmptyInteractionMessage) {
			fields := []logging.Field{
				logging.WithError(err),
			}

			var plannerOutputErr interactionplanning.OutputError
			if errors.As(err, &plannerOutputErr) {
				fields = append(fields, logging.WithField("planner_raw_output", plannerOutputErr.RawOutput))
			}

			handler.logger.Error(ctx, "interaction failed", fields...)
		}
		status, errorCode := handler.mapInteractionError(err)
		network.WriteJSONError(w, status, errorCode)
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
	result, err := handler.processor.Process(ctx, interactionInput)
	if err != nil {
		return InteractionResponse{}, err
	}
	if result.UpdatedSession != nil {
		handler.sessionRepo.Save(*result.UpdatedSession)
	}

	return handler.mapToResponse(result), nil
}

func (handler *InteractionHandler) mapInteractionError(err error) (int, string) {
	if errors.Is(err, ErrNoSessionProvided) {
		return http.StatusBadRequest, errorCodeMissingSession
	}
	if errors.Is(err, interaction.ErrEmptyInteractionMessage) {
		return http.StatusBadRequest, errorCodeEmptyMessage
	}
	if errors.Is(err, ErrNoSessionFound) {
		return http.StatusNotFound, errorCodeSessionNotFound
	}
	return http.StatusInternalServerError, network.ErrorCodeInternal
}

func (handler *InteractionHandler) mapToResponse(result interactionresponse.Result) InteractionResponse {
	return InteractionResponse{
		Message: result.Message,
	}
}
