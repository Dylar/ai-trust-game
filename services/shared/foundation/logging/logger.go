package logging

import "context"

type LogLevel string

const (
	Debug LogLevel = "DEBUG"
	Info  LogLevel = "INFO"
	Warn  LogLevel = "WARN"
	Error LogLevel = "ERROR"
)

func (level LogLevel) IsValid() bool {
	switch level {
	case Debug, Info, Warn, Error:
		return true
	default:
		return false
	}
}

type Field struct {
	Key   string
	Value any
}

type Logger interface {
	Debug(ctx context.Context, msg string, fields ...Field)
	Info(ctx context.Context, msg string, fields ...Field)
	Warn(ctx context.Context, msg string, fields ...Field)
	Error(ctx context.Context, msg string, fields ...Field)
}

func WithField(key string, value any) Field {
	return Field{
		Key:   key,
		Value: value,
	}
}

func WithError(err error) Field {
	return WithField("error", err.Error())
}

type fieldLogger struct {
	base   Logger
	fields []Field
}

func NewFieldLogger(base Logger, fields ...Field) Logger {
	loggerFields := make([]Field, len(fields))
	copy(loggerFields, fields)

	return &fieldLogger{
		base:   base,
		fields: loggerFields,
	}
}

func WithFields(base Logger, fields ...Field) Logger {
	return NewFieldLogger(base, fields...)
}

func (l *fieldLogger) Debug(ctx context.Context, msg string, fields ...Field) {
	l.base.Debug(ctx, msg, l.withFields(fields)...)
}

func (l *fieldLogger) Info(ctx context.Context, msg string, fields ...Field) {
	l.base.Info(ctx, msg, l.withFields(fields)...)
}

func (l *fieldLogger) Warn(ctx context.Context, msg string, fields ...Field) {
	l.base.Warn(ctx, msg, l.withFields(fields)...)
}

func (l *fieldLogger) Error(ctx context.Context, msg string, fields ...Field) {
	l.base.Error(ctx, msg, l.withFields(fields)...)
}

func (l *fieldLogger) withFields(fields []Field) []Field {
	allFields := make([]Field, 0, len(l.fields)+len(fields))
	allFields = append(allFields, l.fields...)
	allFields = append(allFields, fields...)

	return allFields
}
