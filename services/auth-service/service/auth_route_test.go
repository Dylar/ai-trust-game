package service

import (
	"encoding/json"
	"net/http"
	"testing"

	"github.com/Dylar/ai-trust-game/services/auth-service/service/user"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

func TestAuthPrefixedUsersRoute(t *testing.T) {
	repo := user.NewInMemoryRepository()
	createdUser, err := repo.Create(t.Context(), "Kolja")
	if err != nil {
		t.Fatalf("seed user: %v", err)
	}

	mux := http.NewServeMux()
	logger := logging.NewNoopLogger()
	SetupRoutes(mux, logger, NewHealthHandler(), NewUserHandler(repo))

	rec := tests.ExecuteRequest(mux, http.MethodGet, "/auth/users", nil, "")

	assert.Equal(t, rec.Code, http.StatusOK, "unexpected status code")

	var response ListUsersResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatalf("unmarshal list users response: %v", err)
	}

	assert.Equal(t, len(response.Users), 1, "unexpected user count")
	assert.Equal(t, response.Users[0].UserID, createdUser.ID, "unexpected user id")
	assert.Equal(t, response.Users[0].DisplayName, "Kolja", "unexpected display name")
}

func TestAuthPrefixedUserSelectRoute(t *testing.T) {
	repo := user.NewInMemoryRepository()
	createdUser, err := repo.Create(t.Context(), "Kolja")
	if err != nil {
		t.Fatalf("seed user: %v", err)
	}

	mux := http.NewServeMux()
	logger := logging.NewNoopLogger()
	SetupRoutes(mux, logger, NewHealthHandler(), NewUserHandler(repo))

	rec := tests.ExecuteRequest(
		mux,
		http.MethodPost,
		"/auth/users/select",
		map[string]string{"Content-Type": "application/json"},
		`{"userId":"`+createdUser.ID+`"}`,
	)

	assert.Equal(t, rec.Code, http.StatusOK, "unexpected status code")

	var response UserResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatalf("unmarshal user response: %v", err)
	}

	assert.Equal(t, response.UserID, createdUser.ID, "unexpected user id")
	assert.Equal(t, response.DisplayName, "Kolja", "unexpected display name")
}
