package interaction

type ResponseDataGuard interface {
	Guard(input ResponseInput) ResponseInput
}
