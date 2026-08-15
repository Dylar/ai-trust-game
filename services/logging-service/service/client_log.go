package service

import (
	"context"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
)

type ClientLogSink interface {
	WriteClientLog(context.Context, ClientLogRequest) error
}

func ValidateClientLog(req ClientLogRequest) error {
	if req.Message == "" {
		return ErrMissingClientLogMessage
	}
	if req.Category == "" {
		return ErrMissingClientLogCategory
	}
	if !logging.LogLevel(req.Level).IsValid() {
		return ErrInvalidClientLogLevel
	}
	return nil
}

type StructuredClientLogSink struct {
	logger logging.Logger
}

func NewStructuredClientLogSink(logger logging.Logger) *StructuredClientLogSink {
	return &StructuredClientLogSink{logger: logger}
}

func (sink *StructuredClientLogSink) WriteClientLog(ctx context.Context, req ClientLogRequest) error {
	fields := []logging.Field{
		logging.WithField("client_log_category", req.Category),
		logging.WithField("client_log_message", req.Message),
	}
	if len(req.Attributes) > 0 {
		fields = append(fields, logging.WithField("client_log_attributes", req.Attributes))
	}

	const logMsg = "client log received"
	switch logging.LogLevel(req.Level) {
	case logging.Debug:
		sink.logger.Debug(ctx, logMsg, fields...)
	case logging.Info:
		sink.logger.Info(ctx, logMsg, fields...)
	case logging.Warn:
		sink.logger.Warn(ctx, logMsg, fields...)
	case logging.Error:
		sink.logger.Error(ctx, logMsg, fields...)
	}
	return nil
}
