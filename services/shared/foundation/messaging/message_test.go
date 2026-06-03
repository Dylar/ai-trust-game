package messaging

import (
	"errors"
	"testing"
)

func TestShouldRequeue(t *testing.T) {
	t.Run("requeues normal errors", func(t *testing.T) {
		if !ShouldRequeue(errors.New("processing failed")) {
			t.Fatal("expected normal error to requeue")
		}
	})

	t.Run("does not requeue rejected messages", func(t *testing.T) {
		if ShouldRequeue(Reject(errors.New("invalid payload"))) {
			t.Fatal("expected rejected message to skip requeue")
		}
	})
}
