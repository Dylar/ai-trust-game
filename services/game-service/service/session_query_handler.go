package service

import (
	"net/http"
	"strings"

	"github.com/Dylar/ai-trust-game/services/game-service/service/session"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
	"github.com/Dylar/ai-trust-game/services/shared/project/domain"
)

type SessionQueryHandler struct {
	sessionRepo session.Repository
}

func NewSessionQueryHandler(sessionRepo session.Repository) *SessionQueryHandler {
	return &SessionQueryHandler{sessionRepo: sessionRepo}
}

func (handler *SessionQueryHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodGet {
		network.WriteJSONError(w, http.StatusMethodNotAllowed, network.ErrorCodeMethodNotAllowed)
		return
	}

	meta := network.GetMetadata(req.Context())
	if meta.UserID == "" {
		network.WriteJSONError(w, http.StatusBadRequest, errorCodeMissingUser)
		return
	}

	if req.URL.Path == "/session/list" {
		handler.listSessions(w, req, meta.UserID)
		return
	}

	sessionID := strings.TrimPrefix(req.URL.Path, "/session/")
	if sessionID == "" {
		network.WriteJSONError(w, http.StatusNotFound, errorCodeSessionNotFound)
		return
	}
	handler.getSession(w, req, meta.UserID, sessionID)
}

func (handler *SessionQueryHandler) listSessions(w http.ResponseWriter, req *http.Request, userID string) {
	sessions, err := handler.sessionRepo.ListByUserID(req.Context(), userID)
	if err != nil {
		network.WriteJSONError(w, http.StatusInternalServerError, network.ErrorCodeInternal)
		return
	}

	response := ListSessionsResponse{
		Sessions: make([]SessionSummaryResponse, 0, len(sessions)),
	}
	for _, sess := range sessions {
		response.Sessions = append(response.Sessions, toSessionSummaryResponse(sess))
	}

	network.WriteJSON(w, http.StatusOK, response)
}

func (handler *SessionQueryHandler) getSession(w http.ResponseWriter, req *http.Request, userID string, sessionID string) {
	sess, found, err := handler.sessionRepo.Get(req.Context(), sessionID)
	if err != nil {
		network.WriteJSONError(w, http.StatusInternalServerError, network.ErrorCodeInternal)
		return
	}
	if !found || sess.UserID != userID {
		network.WriteJSONError(w, http.StatusNotFound, errorCodeSessionNotFound)
		return
	}

	network.WriteJSON(w, http.StatusOK, toSessionDetailResponse(sess))
}

func toSessionSummaryResponse(sess domain.Session) SessionSummaryResponse {
	return SessionSummaryResponse{
		SessionID: sess.ID,
		UserID:    sess.UserID,
		Role:      string(sess.Settings.Role),
		Mode:      string(sess.Settings.Mode),
		CreatedAt: sess.CreatedAt.Format(timeFormatRFC3339Nano),
		UpdatedAt: sess.UpdatedAt.Format(timeFormatRFC3339Nano),
	}
}

func toSessionDetailResponse(sess domain.Session) SessionDetailResponse {
	return SessionDetailResponse{
		SessionID:      sess.ID,
		UserID:         sess.UserID,
		Role:           string(sess.Settings.Role),
		Mode:           string(sess.Settings.Mode),
		TrustedRole:    string(sess.State.TrustedRole),
		SecretUnlocked: sess.State.SecretUnlocked,
		CreatedAt:      sess.CreatedAt.Format(timeFormatRFC3339Nano),
		UpdatedAt:      sess.UpdatedAt.Format(timeFormatRFC3339Nano),
	}
}

const timeFormatRFC3339Nano = "2006-01-02T15:04:05.999999999Z07:00"
