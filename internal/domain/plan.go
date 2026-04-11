package domain

type Plan struct {
	Action            Action `json:"action"`
	Claims            Claims `json:"claims"`
	SubmittedPassword string `json:"submitted_password"`
}
