package service

type ClientLogRequest struct {
	Level      string                 `json:"level"`
	Category   string                 `json:"category"`
	Message    string                 `json:"message"`
	Attributes map[string]interface{} `json:"attributes"`
}
