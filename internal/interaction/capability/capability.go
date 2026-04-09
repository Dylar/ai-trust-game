package capability

import "github.com/Dylar/ai-trust-game/internal/domain"

type Resolver interface {
	For(mode domain.Mode, input Input) Set
}

type Input struct {
	Session domain.Session
	Claims  domain.Claims
}

type Set struct {
	CanChat                 bool
	CanListAvailableActions bool
	CanSubmitAdminPassword  bool
	CanReadUserProfile      bool
	CanReadSecret           bool
}
