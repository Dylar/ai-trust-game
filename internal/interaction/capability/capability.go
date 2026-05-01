package capability

import "github.com/Dylar/ai-trust-game/internal/domain"

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

func For(mode domain.Mode, input Input) Set {
	set := Set{
		CanChat:                 true,
		CanListAvailableActions: true,
		CanSubmitAdminPassword:  true,
	}

	switch mode {
	case domain.ModeEasy:
		set.CanReadUserProfile = true
		set.CanReadSecret = true
	case domain.ModeMedium:
		set.CanReadUserProfile = canReadUserProfileMedium(input)
		set.CanReadSecret = canReadSecretMedium(input)
	case domain.ModeHard:
		set.CanReadUserProfile = canReadUserProfileHard(input)
		set.CanReadSecret = canReadSecretHard(input)
	}

	return set
}

func canReadUserProfileMedium(input Input) bool {
	if input.Claims.Role == domain.RoleAdmin || input.Claims.Role == domain.RoleEmployee {
		return true
	}
	if input.Session.State.TrustedRole == domain.RoleAdmin || input.Session.State.TrustedRole == domain.RoleEmployee {
		return true
	}
	return input.Session.Settings.Role == domain.RoleAdmin || input.Session.Settings.Role == domain.RoleEmployee
}

func canReadSecretMedium(input Input) bool {
	if input.Claims.Role == domain.RoleAdmin {
		return true
	}
	if input.Session.State.SecretUnlocked || input.Session.State.TrustedRole == domain.RoleAdmin {
		return true
	}
	return input.Session.Settings.Role == domain.RoleAdmin
}

func canReadUserProfileHard(input Input) bool {
	return input.Session.Settings.Role == domain.RoleAdmin || input.Session.Settings.Role == domain.RoleEmployee
}

func canReadSecretHard(input Input) bool {
	if input.Session.State.SecretUnlocked {
		return true
	}
	return input.Session.Settings.Role == domain.RoleAdmin
}
