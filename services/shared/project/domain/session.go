package domain

import "time"

type Session struct {
	ID        string
	UserID    string
	Settings  GameSettings
	State     GameState
	CreatedAt time.Time
	UpdatedAt time.Time
}

type GameSettings struct {
	Role Role
	Mode Mode
}

type GameState struct {
	TrustedRole    Role
	SecretUnlocked bool
}
