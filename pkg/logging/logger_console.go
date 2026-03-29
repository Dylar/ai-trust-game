package logging

import (
	"context"
	"fmt"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"strings"
	"time"
)

type ConsoleLogger struct{}

func NewConsoleLogger() *ConsoleLogger {
	return &ConsoleLogger{}
}

func (l *ConsoleLogger) log(ctx context.Context, level, msg string, fields ...Field) {
	meta := network.GetMetadata(ctx)

	if meta.RequestID != "" {
		fields = append(fields, WithField("request_id", meta.RequestID))
	}

	if meta.SessionID != "" {
		fields = append(fields, WithField("session_id", meta.SessionID))
	}

	if meta.UserID != "" {
		fields = append(fields, WithField("user_id", meta.UserID))
	}

	fmt.Printf(
		"ts=%q level=%s msg=%q %s\n",
		time.Now().Format(time.RFC3339),
		level,
		msg,
		formatFields(fields),
	)
}

func (l *ConsoleLogger) Debug(ctx context.Context, msg string, fields ...Field) {
	l.log(ctx, "DEBUG", msg, fields...)
}

func (l *ConsoleLogger) Info(ctx context.Context, msg string, fields ...Field) {
	l.log(ctx, "INFO", msg, fields...)
}

func (l *ConsoleLogger) Warn(ctx context.Context, msg string, fields ...Field) {
	l.log(ctx, "WARN", msg, fields...)
}

func (l *ConsoleLogger) Error(ctx context.Context, msg string, fields ...Field) {
	l.log(ctx, "ERROR", msg, fields...)
}

func formatFields(fields []Field) string {
	parts := make([]string, 0, len(fields))

	for _, field := range fields {
		parts = append(parts, fmt.Sprintf("%s=%v", field.Key, field.Value))
	}

	return strings.Join(parts, " ")
}
