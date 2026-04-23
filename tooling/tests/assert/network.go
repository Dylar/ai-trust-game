package assert

import (
	"encoding/json"
	"testing"
)

func ErrorCode(t *testing.T, body []byte, expectedCode string) {
	t.Helper()

	var response struct {
		Error struct {
			Code string `json:"code"`
		} `json:"error"`
	}
	if err := json.Unmarshal(body, &response); err != nil {
		t.Fatalf("failed to unmarshal error response body: %v", err)
	}

	Equal(t, response.Error.Code, expectedCode, "unexpected error code")
}
