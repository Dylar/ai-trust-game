package auditclient

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/url"
	"strings"

	"github.com/Dylar/ai-trust-game/services/shared/project/audit"
)

type HTTPSink struct {
	client *http.Client
	url    string
}

func NewHTTPSink(client *http.Client, baseURL string) (*HTTPSink, error) {
	if client == nil {
		client = http.DefaultClient
	}

	base, err := url.Parse(strings.TrimRight(baseURL, "/"))
	if err != nil || base.Scheme == "" || base.Host == "" {
		return nil, ErrInvalidAuditServiceURL
	}

	return &HTTPSink{
		client: client,
		url:    base.String() + "/audit/events",
	}, nil
}

func (sink *HTTPSink) WriteEvent(ctx context.Context, event audit.Event) error {
	var body bytes.Buffer
	if err := json.NewEncoder(&body).Encode(event); err != nil {
		return err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, sink.url, &body)
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := sink.client.Do(req)
	if err != nil {
		return err
	}
	defer func() {
		_ = resp.Body.Close()
	}()

	if resp.StatusCode < http.StatusOK || resp.StatusCode >= http.StatusMultipleChoices {
		return ErrAuditServiceRejectedEvent
	}

	return nil
}
