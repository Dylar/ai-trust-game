package user

import (
	"errors"
	"time"
)

var (
	ErrDuplicateDisplayName = errors.New("user display name already exists")
	ErrInvalidDisplayName   = errors.New("user display name is invalid")
	ErrMissingDisplayName   = errors.New("user display name is missing")
	ErrMissingID            = errors.New("user id is missing")
	ErrNotFound             = errors.New("user not found")
)

type User struct {
	ID          string
	DisplayName string
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
