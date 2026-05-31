package service

type StartSessionRequest struct {
	Role string `json:"role"`
	Mode string `json:"mode"`
}

type StartSessionResponse struct {
	SessionID string `json:"sessionId"`
	Role      string `json:"role"`
	Mode      string `json:"mode"`
}
