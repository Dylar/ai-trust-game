package service

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
)

var ErrInvalidClientLogLevel = errors.New("client log level is invalid")
var ErrMissingClientLogMessage = errors.New("client log message is missing")
var ErrMissingClientLogCategory = errors.New("client log category is missing")

type ClientLogHandler struct {
	logger logging.Logger
}

func NewClientLogHandler(logger logging.Logger) *ClientLogHandler {
	return &ClientLogHandler{logger: logger}
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
	if req.Message == "" {
		return ErrMissingClientLogMessage
	}

	if req.Category == "" {
		return ErrMissingClientLogCategory
	}

	fields := []logging.Field{
		logging.WithField("client_log_category", req.Category),
		logging.WithField("client_log_message", req.Message),
	}

	if len(req.Attributes) > 0 {
		fields = append(fields, logging.WithField("client_log_attributes", req.Attributes))
	}

	logMsg := "client log received"
	switch logging.LogLevel(req.Level) {
	case logging.Debug:
		handler.logger.Debug(ctx, logMsg, fields...)
	case logging.Info:
		handler.logger.Info(ctx, logMsg, fields...)
	case logging.Warn:
		handler.logger.Warn(ctx, logMsg, fields...)
	case logging.Error:
		handler.logger.Error(ctx, logMsg, fields...)
	default:
		return ErrInvalidClientLogLevel
	}

	return nil
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
