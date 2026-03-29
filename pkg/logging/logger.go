package logging

import "context"

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

func WithFields(base Logger, fields ...Field) Logger {
	return &fieldLogger{
		base:   base,
		fields: fields,
	}
}

func (l *fieldLogger) Debug(ctx context.Context, msg string, fields ...Field) {
	l.base.Debug(ctx, msg, append(l.fields, fields...)...)
}

func (l *fieldLogger) Info(ctx context.Context, msg string, fields ...Field) {
	l.base.Info(ctx, msg, append(l.fields, fields...)...)
}

func (l *fieldLogger) Warn(ctx context.Context, msg string, fields ...Field) {
	l.base.Warn(ctx, msg, append(l.fields, fields...)...)
}

func (l *fieldLogger) Error(ctx context.Context, msg string, fields ...Field) {
	l.base.Error(ctx, msg, append(l.fields, fields...)...)
}
