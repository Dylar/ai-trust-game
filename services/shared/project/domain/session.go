package domain

type Session struct {
	ID       string
	Settings GameSettings
	State    GameState
}

type GameSettings struct {
	Role Role
	Mode Mode
}

type GameState struct {
	TrustedRole    Role
	SecretUnlocked bool
}
