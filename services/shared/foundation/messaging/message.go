package messaging

import (
	"context"
	"errors"
)

type Message struct {
	ContentType string
	Body        []byte
}

type Publisher interface {
	Publish(context.Context, Message) error
}

type Consumer interface {
	Run(context.Context) error
}

type Handler func(context.Context, Message) error

type Closer interface {
	Close() error
}

type PublisherCloser interface {
	Publisher
	Closer
}

type ConsumerCloser interface {
	Consumer
	Closer
}

var ErrReject = errors.New("reject message")

type rejectError struct {
	err error
}

func Reject(err error) error {
	if err == nil {
		return ErrReject
	}
	return rejectError{err: err}
}

func (err rejectError) Error() string {
	return err.err.Error()
}

func (err rejectError) Unwrap() error {
	return ErrReject
}

func ShouldRequeue(err error) bool {
	return !errors.Is(err, ErrReject)
}
