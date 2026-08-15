package service

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
)

var ErrInvalidClientLogLevel = errors.New("client log level is invalid")
var ErrMissingClientLogMessage = errors.New("client log message is missing")
var ErrMissingClientLogCategory = errors.New("client log category is missing")

type ClientLogHandler struct {
	sink ClientLogSink
}

func NewClientLogHandler(sink ClientLogSink) *ClientLogHandler {
	return &ClientLogHandler{sink: sink}
}

func (handler *ClientLogHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	ctx := req.Context()

	if req.Method != http.MethodPost {
		network.WriteJSONError(w, http.StatusMethodNotAllowed, network.ErrorCodeMethodNotAllowed)
		return
	}
	defer func() {
		_ = req.Body.Close()
	}()

	var request ClientLogRequest
	if err := json.NewDecoder(req.Body).Decode(&request); err != nil {
		network.WriteJSONError(w, http.StatusBadRequest, network.ErrorCodeInvalidJSON)
		return
	}

	if err := handler.handleClientLog(ctx, request); err != nil {
		status, errorCode := handler.mapClientLogError(err)
		network.WriteJSONError(w, status, errorCode)
		return
	}

	w.WriteHeader(http.StatusAccepted)
}

func (handler *ClientLogHandler) handleClientLog(ctx context.Context, req ClientLogRequest) error {
	if err := ValidateClientLog(req); err != nil {
		return err
	}
	return handler.sink.WriteClientLog(ctx, req)
}

func (handler *ClientLogHandler) mapClientLogError(err error) (int, string) {
	if errors.Is(err, ErrMissingClientLogMessage) {
		return http.StatusBadRequest, errorCodeMissingClientLogMessage
	}

	if errors.Is(err, ErrMissingClientLogCategory) {
		return http.StatusBadRequest, errorCodeMissingClientLogCategory
	}

	if errors.Is(err, ErrInvalidClientLogLevel) {
		return http.StatusBadRequest, errorCodeInvalidClientLogLevel
	}

	return http.StatusInternalServerError, network.ErrorCodeInternal
}
