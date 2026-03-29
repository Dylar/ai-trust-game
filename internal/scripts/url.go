package scripts

import "os"

const defaultBaseURL = "http://localhost:8080"

func BaseURL() string {
	if v := os.Getenv("BASE_URL"); v != "" {
		return v
	}
	return defaultBaseURL
}
