package audit

import "context"

type Sink interface {
	WriteEvent(ctx context.Context, event Event) error
}
