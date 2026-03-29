package network

import "context"

type contextKey string

const metadataKey contextKey = "request_metadata"

type Metadata struct {
	RequestID string
	SessionID string
	UserID    string
}

func WithMetadata(ctx context.Context, m Metadata) context.Context {
	return context.WithValue(ctx, metadataKey, m)
}

func GetMetadata(ctx context.Context) Metadata {
	meta, _ := ctx.Value(metadataKey).(Metadata)
	return meta
}
