package logging

import (
	"context"
	"testing"

	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

func TestFieldLoggerLogsConstructorFields(t *testing.T) {
	type Given struct {
		loggerFields []Field
		logFields    []Field
	}

	type Then struct {
		expectedLevel   LogLevel
		expectedMessage string
		expectedFields  []Field
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN logger fields and log fields " +
				"WHEN Info is called " +
				"THEN writes logger fields before log fields",
			given: Given{
				loggerFields: []Field{
					WithField("service", "game-service"),
					WithField("env", "test"),
				},
				logFields: []Field{
					WithField("request", "value"),
				},
			},
			then: Then{
				expectedLevel:   Info,
				expectedMessage: "message",
				expectedFields: []Field{
					WithField("service", "game-service"),
					WithField("env", "test"),
					WithField("request", "value"),
				},
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			base := &recordingLogger{}
			logger := NewFieldLogger(base, given.loggerFields...)

			logger.Info(context.Background(), then.expectedMessage, given.logFields...)

			assert.Equal(t, base.level, then.expectedLevel, "unexpected log level")
			assert.Equal(t, base.message, then.expectedMessage, "unexpected log message")
			assert.Equal(t, len(base.fields), len(then.expectedFields), "unexpected field count")

			for index, expectedField := range then.expectedFields {
				assert.Equal(t, base.fields[index].Key, expectedField.Key, "unexpected field key")
				assert.Equal(t, base.fields[index].Value, expectedField.Value, "unexpected field value")
			}
		})
	}
}

type recordingLogger struct {
	level   LogLevel
	message string
	fields  []Field
}

func (l *recordingLogger) Debug(_ context.Context, msg string, fields ...Field) {
	l.record(Debug, msg, fields...)
}

func (l *recordingLogger) Info(_ context.Context, msg string, fields ...Field) {
	l.record(Info, msg, fields...)
}

func (l *recordingLogger) Warn(_ context.Context, msg string, fields ...Field) {
	l.record(Warn, msg, fields...)
}

func (l *recordingLogger) Error(_ context.Context, msg string, fields ...Field) {
	l.record(Error, msg, fields...)
}

func (l *recordingLogger) record(level LogLevel, msg string, fields ...Field) {
	l.level = level
	l.message = msg
	l.fields = fields
}
