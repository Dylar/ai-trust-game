package domain

type Action string

const (
	ActionChat                Action = "chat"
	ActionReadSecret          Action = "read_secret"
	ActionReadUserProfile     Action = "read_user_profile"
	ActionSubmitAdminPassword Action = "submit_admin_password"
)
