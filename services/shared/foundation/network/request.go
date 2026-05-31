package network

import (
	"github.com/google/uuid"
	"net/http"
)

const RequestIDHeader = "X-Request-Id"
const SessionIDHeader = "X-Session-Id"
const UserIDHeader = "X-User-Id"

func RequestMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requestID := uuid.NewString()
		w.Header().Set(RequestIDHeader, requestID)
		sessionID := r.Header.Get(SessionIDHeader)
		userID := r.Header.Get(UserIDHeader)

		meta := Metadata{
			RequestID: requestID,
			SessionID: sessionID,
			UserID:    userID,
		}

		ctx := WithMetadata(r.Context(), meta)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
