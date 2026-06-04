package service

type ChatRequest struct {
	SessionID string `json:"sessionId"`
	Message   string `json:"message"`
}
type ChatResponse struct {
	Message string `json:"message"`
}
