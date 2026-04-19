package service

type RequestAnalysisResponse struct {
	RequestID      string   `json:"request_id"`
	Classification string   `json:"classification"`
	Signals        []string `json:"signals"`
	EventCount     int      `json:"event_count"`
	SuspicionCount int      `json:"suspicion_count"`
	ModelFailCount int      `json:"model_fail_count"`
}
