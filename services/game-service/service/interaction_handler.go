package service

import (
	"context"
	"encoding/json"
	"errors"
	"github.com/Dylar/ai-trust-game/services/game-service/service/game"
	interactionplanning "github.com/Dylar/ai-trust-game/services/game-service/service/game/planning"
	interactionresponse "github.com/Dylar/ai-trust-game/services/game-service/service/game/response"
	"github.com/Dylar/ai-trust-game/services/game-service/service/interaction"
	"github.com/Dylar/ai-trust-game/services/shared/project/domain"
	"net/http"
	"strings"
	"time"

	"github.com/Dylar/ai-trust-game/services/game-service/service/session"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
	"github.com/google/uuid"
)

var ErrNoSessionFound = errors.New("no session found")
var ErrNoSessionProvided = errors.New("no session provided")

type InteractionHandler struct {
	logger          logging.Logger
	sessionRepo     session.Repository
	interactionRepo interaction.Repository
	processor       game.Processor
}

func NewInteractionHandler(
	logger logging.Logger,
	sessionRepo session.Repository,
	processor game.Processor,
	interactionRepos ...interaction.Repository,
) *InteractionHandler {
	interactionRepo := interaction.Repository(interaction.NewNoopRepository())
	if len(interactionRepos) > 0 && interactionRepos[0] != nil {
		interactionRepo = interactionRepos[0]
	}

	return &InteractionHandler{
		logger:          logger,
		sessionRepo:     sessionRepo,
		interactionRepo: interactionRepo,
		processor:       processor,
	}
}

func (handler *InteractionHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	ctx := req.Context()

	if req.Method == http.MethodGet {
		if !strings.HasPrefix(req.URL.Path, "/interaction/session/") {
			network.WriteJSONError(w, http.StatusMethodNotAllowed, network.ErrorCodeMethodNotAllowed)
			return
		}
		handler.handleInteractionQuery(w, req)
		return
	}

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
			!errors.Is(err, game.ErrEmptyInteractionMessage) {
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

func (handler *InteractionHandler) handleInteractionQuery(w http.ResponseWriter, req *http.Request) {
	sessionID := strings.TrimPrefix(req.URL.Path, "/interaction/session/")
	if sessionID == "" || sessionID == req.URL.Path {
		network.WriteJSONError(w, http.StatusNotFound, errorCodeSessionNotFound)
		return
	}

	response, err := handler.handleListInteractions(req.Context(), sessionID)
	if err != nil {
		status, errorCode := handler.mapInteractionError(err)
		network.WriteJSONError(w, status, errorCode)
		return
	}

	network.WriteJSON(w, http.StatusOK, response)
}

func (handler *InteractionHandler) handleListInteractions(ctx context.Context, sessionID string) (ListInteractionsResponse, error) {
	meta := network.GetMetadata(ctx)
	if meta.UserID == "" {
		return ListInteractionsResponse{}, ErrNoUserProvided
	}

	sess, found, err := handler.sessionRepo.Get(ctx, sessionID)
	if err != nil {
		return ListInteractionsResponse{}, err
	}
	if !found || sess.UserID != meta.UserID {
		return ListInteractionsResponse{}, ErrNoSessionFound
	}

	records, err := handler.interactionRepo.ListBySession(ctx, sessionID)
	if err != nil {
		return ListInteractionsResponse{}, err
	}

	response := ListInteractionsResponse{
		Interactions: make([]InteractionRecordResponse, 0, len(records)),
	}
	for _, record := range records {
		if record.UserID != meta.UserID {
			continue
		}
		response.Interactions = append(response.Interactions, toInteractionRecordResponse(record))
	}

	return response, nil
}

func (handler *InteractionHandler) handleInteraction(ctx context.Context, req InteractionRequest) (InteractionResponse, error) {
	if req.Message == "" {
		return InteractionResponse{}, game.ErrEmptyInteractionMessage
	}

	meta := network.GetMetadata(ctx)
	if meta.SessionID == "" {
		return InteractionResponse{}, ErrNoSessionProvided
	}
	if meta.UserID == "" {
		return InteractionResponse{}, ErrNoUserProvided
	}

	sess, found, err := handler.sessionRepo.Get(ctx, meta.SessionID)
	if err != nil {
		return InteractionResponse{}, err
	}
	if !found {
		return InteractionResponse{}, ErrNoSessionFound
	}
	if sess.UserID != meta.UserID {
		return InteractionResponse{}, ErrNoSessionFound
	}

	handler.logger.Debug(
		ctx,
		"interaction started",
		logging.WithField("session_id", sess.ID),
		logging.WithField("user_id", sess.UserID),
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
		updatedSession := *result.UpdatedSession
		updatedSession.UserID = sess.UserID
		updatedSession.CreatedAt = sess.CreatedAt
		updatedSession.UpdatedAt = time.Now().UTC()
		if err := handler.sessionRepo.Save(ctx, updatedSession); err != nil {
			return InteractionResponse{}, err
		}
	}

	if err := handler.interactionRepo.Save(ctx, interaction.Record{
		ID:             uuid.NewString(),
		SessionID:      sess.ID,
		UserID:         sess.UserID,
		RequestID:      meta.RequestID,
		UserInput:      req.Message,
		SelectedAction: string(result.SelectedAction),
		PolicyResult: interaction.PolicyResult{
			Allowed: result.DecisionAllowed,
			Reason:  result.DecisionReason,
		},
		ResponseText: result.Message,
		Pipeline: interaction.Pipeline{
			ResponseSource: string(result.Source),
		},
		CreatedAt: time.Now().UTC(),
	}); err != nil {
		return InteractionResponse{}, err
	}

	return handler.mapToResponse(result), nil
}

func (handler *InteractionHandler) mapInteractionError(err error) (int, string) {
	if errors.Is(err, ErrNoSessionProvided) {
		return http.StatusBadRequest, errorCodeMissingSession
	}
	if errors.Is(err, ErrNoUserProvided) {
		return http.StatusBadRequest, errorCodeMissingUser
	}
	if errors.Is(err, game.ErrEmptyInteractionMessage) {
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

func toInteractionRecordResponse(record interaction.Record) InteractionRecordResponse {
	return InteractionRecordResponse{
		InteractionID: record.ID,
		SessionID:     record.SessionID,
		RequestID:     record.RequestID,
		Message:       record.UserInput,
		Answer:        record.ResponseText,
		CreatedAt:     record.CreatedAt.Format(timeFormatRFC3339Nano),
	}
}
