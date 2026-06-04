package scripts

import (
	"bytes"
	"encoding/json"
	"net/http"
	"os"
	"strings"
)

const defaultBaseURL = "http://localhost:8080"

func BaseURL() string {
	if v := os.Getenv("BASE_URL"); v != "" {
		return v
	}
	return defaultBaseURL
}

func BuildURL(base, route string) string {
	return strings.TrimRight(base, "/") + route
}

// DoJSONRequest sends a JSON request with optional headers
func DoJSONRequest(method, url string, body any, headers map[string]string) (*http.Response, error) {
	var buf *bytes.Buffer

	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			return nil, err
		}
		buf = bytes.NewBuffer(b)
	} else {
		buf = bytes.NewBuffer(nil)
	}

	req, err := http.NewRequest(method, url, buf)
	if err != nil {
		return nil, err
	}

	// default header
	req.Header.Set("Content-Type", "application/json")

	// custom headers
	for k, v := range headers {
		req.Header.Set(k, v)
	}

	client := &http.Client{}
	return client.Do(req)
}

func DecodeJSONResponse(resp *http.Response, target any) error {
	return json.NewDecoder(resp.Body).Decode(target)
}
