package domain

type Role string

const (
	RoleGuest    Role = "guest"
	RoleEmployee Role = "employee"
	RoleAdmin    Role = "admin"
)

func ParseRole(input string) (Role, bool) {
	switch Role(input) {
	case RoleGuest,
		RoleEmployee,
		RoleAdmin:
		return Role(input), true
	default:
		return "", false
	}
}
