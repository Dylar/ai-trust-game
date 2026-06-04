package network

import (
	"encoding/json"
	"log"
	"net/http"
)

const (
	ErrorCodeInvalidJSON      = "invalid_json"
	ErrorCodeMethodNotAllowed = "method_not_allowed"
	ErrorCodeInternal         = "internal_error"
)

func WriteJSON(w http.ResponseWriter, status int, data any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	if data == nil {
		return
	}

	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("ERROR: failed to encode json response: %v", err)
	}
}

type ErrorResponse struct {
	Error ResponseError `json:"error"`
}

type ResponseError struct {
	Code string `json:"code"`
}

func WriteJSONError(w http.ResponseWriter, status int, code string) {
	WriteJSON(w, status, ErrorResponse{
		Error: ResponseError{
			Code: code,
		},
	})
}
