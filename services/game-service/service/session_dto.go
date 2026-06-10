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

type SessionSummaryResponse struct {
	SessionID string `json:"sessionId"`
	UserID    string `json:"userId"`
	Role      string `json:"role"`
	Mode      string `json:"mode"`
	CreatedAt string `json:"createdAt"`
	UpdatedAt string `json:"updatedAt"`
}

type ListSessionsResponse struct {
	Sessions []SessionSummaryResponse `json:"sessions"`
}

type SessionDetailResponse struct {
	SessionID      string `json:"sessionId"`
	UserID         string `json:"userId"`
	Role           string `json:"role"`
	Mode           string `json:"mode"`
	TrustedRole    string `json:"trustedRole"`
	SecretUnlocked bool   `json:"secretUnlocked"`
	CreatedAt      string `json:"createdAt"`
	UpdatedAt      string `json:"updatedAt"`
}
