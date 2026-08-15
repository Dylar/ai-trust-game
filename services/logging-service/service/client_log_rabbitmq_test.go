package service

import (
	"context"
	"encoding/json"
	"errors"
	"testing"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/messaging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

func TestRabbitMQClientLogSinkPublishesEnvelope(t *testing.T) {
	publisher := &recordingPublisher{}
	sink := &RabbitMQClientLogSink{publisher: publisher}
	request := ClientLogRequest{Level: "INFO", Category: "interaction", Message: "sent"}
	metadata := network.Metadata{RequestID: "request-1", SessionID: "session-1", UserID: "user-1"}

	err := sink.WriteClientLog(network.WithMetadata(context.Background(), metadata), request)

	assert.ErrorIs(t, err, nil, "unexpected publish error")
	assert.Equal(t, publisher.message.ContentType, "application/json", "unexpected content type")
	var envelope clientLogEnvelope
	err = json.Unmarshal(publisher.message.Body, &envelope)
	assert.ErrorIs(t, err, nil, "unexpected envelope")
	assert.Equal(t, envelope.Request.Message, request.Message, "unexpected request")
	assert.Equal(t, envelope.Metadata, metadata, "unexpected metadata")
}

func TestClientLogMessageHandler(t *testing.T) {
	validBody, err := json.Marshal(clientLogEnvelope{
		Request:  ClientLogRequest{Level: "WARN", Category: "network", Message: "slow"},
		Metadata: network.Metadata{RequestID: "request-2"},
	})
	if err != nil {
		t.Fatal(err)
	}

	scenarios := []struct {
		name           string
		body           []byte
		expectedReject bool
		expectedWrite  bool
	}{
		{name: "GIVEN a valid envelope WHEN consumed THEN writes the client log", body: validBody, expectedWrite: true},
		{name: "GIVEN malformed JSON WHEN consumed THEN rejects the message", body: []byte("{"), expectedReject: true},
		{name: "GIVEN an invalid client log WHEN consumed THEN rejects the message", body: []byte(`{"request":{"level":"TRACE","category":"network","message":"slow"}}`), expectedReject: true},
	}

	for _, scenario := range scenarios {
		t.Run(scenario.name, func(t *testing.T) {
			sink := &recordingClientLogSink{}
			err := clientLogMessageHandler(sink)(context.Background(), messaging.Message{Body: scenario.body})
			assert.Equal(t, errors.Is(err, messaging.ErrReject), scenario.expectedReject, "unexpected reject result")
			assert.Equal(t, sink.called, scenario.expectedWrite, "unexpected sink call")
			if scenario.expectedWrite {
				assert.Equal(t, network.GetMetadata(sink.ctx).RequestID, "request-2", "unexpected request metadata")
			}
		})
	}
}

type recordingPublisher struct {
	message messaging.Message
}

func (publisher *recordingPublisher) Publish(_ context.Context, message messaging.Message) error {
	publisher.message = message
	return nil
}

func (publisher *recordingPublisher) Close() error { return nil }

type recordingClientLogSink struct {
	called bool
	ctx    context.Context
}

func (sink *recordingClientLogSink) WriteClientLog(ctx context.Context, _ ClientLogRequest) error {
	sink.called = true
	sink.ctx = ctx
	return nil
}
