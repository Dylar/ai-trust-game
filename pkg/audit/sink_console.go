package audit

import (
	"context"
	"fmt"
	"time"
)

type ConsoleSink struct{}

func NewConsoleSink() *ConsoleSink {
	return &ConsoleSink{}
}

func (s *ConsoleSink) WriteEvent(_ context.Context, event Event) error {
	fmt.Printf(
		"audit ts=%q type=%q request_id=%q session_id=%q user_id=%q outcome=%q suspicion=%q reason=%q input=%q\n",
		event.Timestamp.Format(time.RFC3339),
		event.Type,
		event.RequestID,
		event.SessionID,
		event.UserID,
		event.Outcome,
		event.Suspicion,
		event.Reason,
		event.Input,
	)
	return nil
}
