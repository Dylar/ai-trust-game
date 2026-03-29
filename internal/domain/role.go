package domain

type Role string

const (
	RoleCustomer Role = "customer"
	RoleEmployee Role = "employee"
	RoleAdmin    Role = "admin"
)

func ParseRole(input string) (Role, bool) {
	switch Role(input) {
	case RoleCustomer,
		RoleEmployee,
		RoleAdmin:
		return Role(input), true
	default:
		return "", false
	}
}
