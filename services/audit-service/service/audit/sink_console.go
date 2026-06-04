package audit

import (
	"context"
	"encoding/json"
	"fmt"
)

type ConsoleSink struct{}

func NewConsoleSink() *ConsoleSink {
	return &ConsoleSink{}
}

func (s *ConsoleSink) WriteEvent(_ context.Context, event Event) error {
	payload, err := json.Marshal(event)
	if err != nil {
		return err
	}

	fmt.Println("---///\\\\\\---")
	fmt.Printf("[AUDIT]: %s\n", payload)
	fmt.Println("---\\\\\\///---")
	return nil
}
