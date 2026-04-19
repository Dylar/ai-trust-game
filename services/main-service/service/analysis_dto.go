package service

import "time"

type RequestAnalysisResponse struct {
	RequestID      string    `json:"request_id"`
	SessionID      string    `json:"session_id"`
	CompletedAt    time.Time `json:"completed_at"`
	Classification string    `json:"classification"`
	Signals        []string  `json:"signals"`
	AttackPatterns []string  `json:"attack_patterns"`
	EventCount     int       `json:"event_count"`
	SuspicionCount int       `json:"suspicion_count"`
	ModelFailCount int       `json:"model_fail_count"`
}

type SessionAnalysisResponse struct {
	SessionID      string                    `json:"session_id"`
	Classification string                    `json:"classification"`
	Signals        []string                  `json:"signals"`
	AttackPatterns []string                  `json:"attack_patterns"`
	RequestCount   int                       `json:"request_count"`
	Requests       []RequestAnalysisResponse `json:"requests"`
	SuspicionCount int                       `json:"suspicion_count"`
	ModelFailCount int                       `json:"model_fail_count"`
}
