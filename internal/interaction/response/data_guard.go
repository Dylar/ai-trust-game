package response

type DataGuard interface {
	Guard(input Input) Input
}
