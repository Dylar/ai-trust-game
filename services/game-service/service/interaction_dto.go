package service

type InteractionRequest struct {
	Message string `json:"message"`
}

type InteractionResponse struct {
	Message string `json:"message"`
}

type InteractionRecordResponse struct {
	InteractionID string `json:"interactionId"`
	SessionID     string `json:"sessionId"`
	RequestID     string `json:"requestId"`
	Message       string `json:"message"`
	Answer        string `json:"answer"`
	CreatedAt     string `json:"createdAt"`
}

type ListInteractionsResponse struct {
	Interactions []InteractionRecordResponse `json:"interactions"`
}
