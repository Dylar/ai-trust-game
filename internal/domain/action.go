package domain

type Action string

const (
	ActionChat        Action = "chat"
	ActionReadSecret  Action = "read_secret"
	ActionGetUserInfo Action = "get_user_info"
)
