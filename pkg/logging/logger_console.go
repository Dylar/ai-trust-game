package logging

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/Dylar/ai-trust-game/pkg/network"
)

type ConsoleLogger struct{}

func NewConsoleLogger() *ConsoleLogger {
	return &ConsoleLogger{}
}

func (l *ConsoleLogger) log(ctx context.Context, level LogLevel, msg string, fields ...Field) {
	if !level.IsValid() {
		fmt.Printf("[LOG][ERROR]: invalid level %q\n", level)
		level = Error
	}
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

	fmt.Println("///------\\\\\\")
	logMsg := fmt.Sprintf(
		"[LOG][%s]:\ntime=%q\nmsg=%q\n%s",
		level,
		time.Now().Format(time.RFC3339),
		msg,
		formatFields(fields),
	)
	fmt.Println(logMsg)
	fmt.Println("\\\\\\------///")
}

func (l *ConsoleLogger) Debug(ctx context.Context, msg string, fields ...Field) {
	l.log(ctx, Debug, msg, fields...)
}

func (l *ConsoleLogger) Info(ctx context.Context, msg string, fields ...Field) {
	l.log(ctx, Info, msg, fields...)
}

func (l *ConsoleLogger) Warn(ctx context.Context, msg string, fields ...Field) {
	l.log(ctx, Warn, msg, fields...)
}

func (l *ConsoleLogger) Error(ctx context.Context, msg string, fields ...Field) {
	l.log(ctx, Error, msg, fields...)
}

func formatFields(fields []Field) string {
	parts := make([]string, 0, len(fields))

	for _, field := range fields {
		parts = append(parts, fmt.Sprintf("%s=%v", field.Key, field.Value))
	}

	return strings.Join(parts, "\n")
}
