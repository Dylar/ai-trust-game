package tests

import (
	"bytes"
	"net/http"
	"net/http/httptest"
)

func ExecuteRequest(
	handler http.Handler,
	method string,
	path string,
	headers map[string]string,
	body string,
) *httptest.ResponseRecorder {
	req := httptest.NewRequest(
		method,
		path,
		bytes.NewBufferString(body),
	)

	for key, value := range headers {
		req.Header.Set(key, value)
	}

	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	return rec
}
