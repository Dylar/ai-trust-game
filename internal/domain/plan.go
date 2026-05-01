package domain

const DefaultResponseLanguage = "en"

type Plan struct {
	Action            Action `json:"action"`
	Claims            Claims `json:"claims"`
	SubmittedPassword string `json:"submitted_password"`
	ResponseLanguage  string `json:"response_language"`
}
