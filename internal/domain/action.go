package domain

import "fmt"

type Action string

const (
	ActionChat                 Action = "chat"
	ActionListAvailableActions Action = "list_available_actions"
	ActionReadSecret           Action = "read_secret"
	ActionReadUserProfile      Action = "read_user_profile"
	ActionSubmitAdminPassword  Action = "submit_admin_password"
)

func ParseAction(input Action) (Action, error) {
	switch input {
	case ActionChat,
		ActionListAvailableActions,
		ActionReadSecret,
		ActionReadUserProfile,
		ActionSubmitAdminPassword:
		return input, nil
	default:
		return "", fmt.Errorf("unknown planner action %q", input)
	}
}
