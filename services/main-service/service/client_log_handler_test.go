package service

import (
	"context"
	"testing"

	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestHandleClientLog(t *testing.T) {
	type Given struct {
		request ClientLogRequest
	}

	type Then struct {
		expectedError error
		expectedLevel string
		expectedMsg   string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN valid info log " +
				"WHEN handleClientLog is called " +
				"THEN writes the log with info level",
			given: Given{
				request: ClientLogRequest{
					Level:    "info",
					Category: "interaction",
					Message:  "message sent",
				},
			},
			then: Then{
				expectedLevel: "info",
				expectedMsg:   "client log received",
			},
		},
		{
			name: "GIVEN missing message " +
				"WHEN handleClientLog is called " +
				"THEN returns ErrMissingClientLogMessage",
			given: Given{
				request: ClientLogRequest{
					Level:    "info",
					Category: "interaction",
				},
			},
			then: Then{
				expectedError: ErrMissingClientLogMessage,
			},
		},
		{
			name: "GIVEN missing category " +
				"WHEN handleClientLog is called " +
				"THEN returns ErrMissingClientLogCategory",
			given: Given{
				request: ClientLogRequest{
					Level:   "info",
					Message: "message sent",
				},
			},
			then: Then{
				expectedError: ErrMissingClientLogCategory,
			},
		},
		{
			name: "GIVEN invalid level " +
				"WHEN handleClientLog is called " +
				"THEN returns ErrInvalidClientLogLevel",
			given: Given{
				request: ClientLogRequest{
					Level:    "trace",
					Category: "interaction",
					Message:  "message sent",
				},
			},
			then: Then{
				expectedError: ErrInvalidClientLogLevel,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			logger := &recordingLogger{}
			handler := NewClientLogHandler(logger)

			err := handler.handleClientLog(context.Background(), given.request)

			assert.ErrorIs(t, err, then.expectedError, "unexpected error")

			if then.expectedError != nil {
				return
			}

			assert.Equal(t, logger.lastLevel, then.expectedLevel, "unexpected log level")
			assert.Equal(t, logger.lastMessage, then.expectedMsg, "unexpected log message")
		})
	}
}

type recordingLogger struct {
	lastLevel   string
	lastMessage string
}

func (l *recordingLogger) Debug(_ context.Context, msg string, _ ...logging.Field) {
	l.lastLevel = "debug"
	l.lastMessage = msg
}

func (l *recordingLogger) Info(_ context.Context, msg string, _ ...logging.Field) {
	l.lastLevel = "info"
	l.lastMessage = msg
}

func (l *recordingLogger) Warn(_ context.Context, msg string, _ ...logging.Field) {
	l.lastLevel = "warning"
	l.lastMessage = msg
}

func (l *recordingLogger) Error(_ context.Context, msg string, _ ...logging.Field) {
	l.lastLevel = "error"
	l.lastMessage = msg
}
