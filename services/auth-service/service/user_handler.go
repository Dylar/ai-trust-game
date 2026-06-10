package service

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"github.com/Dylar/ai-trust-game/services/auth-service/service/user"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
)

type UserHandler struct {
	repo user.Repository
}

const maxUserDisplayNameLength = 80

func NewUserHandler(repo user.Repository) *UserHandler {
	return &UserHandler{repo: repo}
}

func (handler *UserHandler) ServeUsersHTTP(w http.ResponseWriter, req *http.Request) {
	switch req.Method {
	case http.MethodGet:
		handler.listUsers(w, req)
	case http.MethodPost:
		handler.createUser(w, req)
	default:
		network.WriteJSONError(w, http.StatusMethodNotAllowed, network.ErrorCodeMethodNotAllowed)
	}
}

func (handler *UserHandler) ServeUserSelectHTTP(w http.ResponseWriter, req *http.Request) {
	if req.Method != http.MethodPost {
		network.WriteJSONError(w, http.StatusMethodNotAllowed, network.ErrorCodeMethodNotAllowed)
		return
	}

	defer func() {
		_ = req.Body.Close()
	}()

	var request SelectUserRequest
	if err := json.NewDecoder(req.Body).Decode(&request); err != nil {
		network.WriteJSONError(w, http.StatusBadRequest, network.ErrorCodeInvalidJSON)
		return
	}

	selectedUser, err := handler.selectUser(req.Context(), request)
	if err != nil {
		status, errorCode := mapUserError(err)
		network.WriteJSONError(w, status, errorCode)
		return
	}

	network.WriteJSON(w, http.StatusOK, toUserResponse(selectedUser))
}

func (handler *UserHandler) listUsers(w http.ResponseWriter, req *http.Request) {
	users, err := handler.repo.List(req.Context())
	if err != nil {
		network.WriteJSONError(w, http.StatusInternalServerError, network.ErrorCodeInternal)
		return
	}

	response := ListUsersResponse{Users: make([]UserResponse, 0, len(users))}
	for _, currentUser := range users {
		response.Users = append(response.Users, toUserResponse(currentUser))
	}

	network.WriteJSON(w, http.StatusOK, response)
}

func (handler *UserHandler) createUser(w http.ResponseWriter, req *http.Request) {
	defer func() {
		_ = req.Body.Close()
	}()

	var request CreateUserRequest
	if err := json.NewDecoder(req.Body).Decode(&request); err != nil {
		network.WriteJSONError(w, http.StatusBadRequest, network.ErrorCodeInvalidJSON)
		return
	}

	createdUser, err := handler.createUserRecord(req.Context(), request)
	if err != nil {
		status, errorCode := mapUserError(err)
		network.WriteJSONError(w, status, errorCode)
		return
	}

	network.WriteJSON(w, http.StatusCreated, toUserResponse(createdUser))
}

func (handler *UserHandler) createUserRecord(ctx context.Context, req CreateUserRequest) (user.User, error) {
	displayName := strings.TrimSpace(req.DisplayName)
	if displayName == "" {
		return user.User{}, user.ErrMissingDisplayName
	}
	if len(displayName) > maxUserDisplayNameLength {
		return user.User{}, user.ErrInvalidDisplayName
	}

	return handler.repo.Create(ctx, displayName)
}

func (handler *UserHandler) selectUser(ctx context.Context, req SelectUserRequest) (user.User, error) {
	userID := strings.TrimSpace(req.UserID)
	if userID == "" {
		return user.User{}, user.ErrMissingID
	}

	selectedUser, found, err := handler.repo.Get(ctx, userID)
	if err != nil {
		return user.User{}, err
	}
	if !found {
		return user.User{}, user.ErrNotFound
	}

	return selectedUser, nil
}

func mapUserError(err error) (int, string) {
	if errors.Is(err, user.ErrMissingDisplayName) {
		return http.StatusBadRequest, errorCodeMissingUserDisplayName
	}
	if errors.Is(err, user.ErrInvalidDisplayName) {
		return http.StatusBadRequest, errorCodeInvalidUserDisplayName
	}
	if errors.Is(err, user.ErrMissingID) {
		return http.StatusBadRequest, errorCodeMissingUserID
	}
	if errors.Is(err, user.ErrDuplicateDisplayName) {
		return http.StatusConflict, errorCodeDuplicateUserDisplayName
	}
	if errors.Is(err, user.ErrNotFound) {
		return http.StatusNotFound, errorCodeUserNotFound
	}

	return http.StatusInternalServerError, network.ErrorCodeInternal
}

func toUserResponse(currentUser user.User) UserResponse {
	return UserResponse{
		UserID:      currentUser.ID,
		DisplayName: currentUser.DisplayName,
		CreatedAt:   currentUser.CreatedAt.Format(timeFormatRFC3339Nano),
		UpdatedAt:   currentUser.UpdatedAt.Format(timeFormatRFC3339Nano),
	}
}

const timeFormatRFC3339Nano = "2006-01-02T15:04:05.999999999Z07:00"
