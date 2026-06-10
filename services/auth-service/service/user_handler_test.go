package service

import (
	"encoding/json"
	"net/http"
	"strings"
	"testing"

	"github.com/Dylar/ai-trust-game/services/auth-service/service/user"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

func TestUserHandlerUsersRoute(t *testing.T) {
	type Given struct {
		method        string
		body          string
		existingUsers []string
	}

	type Then struct {
		expectedStatus    int
		expectedErrorCode string
		expectedUserCount int
		expectedUserName  string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN existing users " +
				"WHEN GET /users " +
				"THEN returns user list",
			given: Given{
				method:        http.MethodGet,
				existingUsers: []string{"Kolja"},
			},
			then: Then{
				expectedStatus:    http.StatusOK,
				expectedUserCount: 1,
				expectedUserName:  "Kolja",
			},
		},
		{
			name: "GIVEN new display name " +
				"WHEN POST /users " +
				"THEN creates user",
			given: Given{
				method: http.MethodPost,
				body:   `{"displayName":"Kolja"}`,
			},
			then: Then{
				expectedStatus:   http.StatusCreated,
				expectedUserName: "Kolja",
			},
		},
		{
			name: "GIVEN display name with surrounding spaces " +
				"WHEN POST /users " +
				"THEN creates user with trimmed name",
			given: Given{
				method: http.MethodPost,
				body:   `{"displayName":"  Kolja  "}`,
			},
			then: Then{
				expectedStatus:   http.StatusCreated,
				expectedUserName: "Kolja",
			},
		},
		{
			name: "GIVEN duplicate display name " +
				"WHEN POST /users " +
				"THEN returns conflict",
			given: Given{
				method:        http.MethodPost,
				body:          `{"displayName":"Kolja"}`,
				existingUsers: []string{"Kolja"},
			},
			then: Then{
				expectedStatus:    http.StatusConflict,
				expectedErrorCode: errorCodeDuplicateUserDisplayName,
			},
		},
		{
			name: "GIVEN missing display name " +
				"WHEN POST /users " +
				"THEN returns validation error",
			given: Given{
				method: http.MethodPost,
				body:   `{"displayName":" "}`,
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: errorCodeMissingUserDisplayName,
			},
		},
		{
			name: "GIVEN too long display name " +
				"WHEN POST /users " +
				"THEN returns validation error",
			given: Given{
				method: http.MethodPost,
				body:   `{"displayName":"` + strings.Repeat("a", maxUserDisplayNameLength+1) + `"}`,
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: errorCodeInvalidUserDisplayName,
			},
		},
		{
			name: "GIVEN invalid JSON " +
				"WHEN POST /users " +
				"THEN returns invalid JSON error",
			given: Given{
				method: http.MethodPost,
				body:   `{`,
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: network.ErrorCodeInvalidJSON,
			},
		},
		{
			name: "GIVEN unsupported method " +
				"WHEN DELETE /users " +
				"THEN returns method not allowed",
			given: Given{method: http.MethodDelete},
			then: Then{
				expectedStatus:    http.StatusMethodNotAllowed,
				expectedErrorCode: network.ErrorCodeMethodNotAllowed,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			repo := user.NewInMemoryRepository()
			for _, displayName := range given.existingUsers {
				if _, err := repo.Create(t.Context(), displayName); err != nil {
					t.Fatalf("seed user: %v", err)
				}
			}

			handler := NewUserHandler(repo)
			rec := tests.ExecuteRequest(
				http.HandlerFunc(handler.ServeUsersHTTP),
				given.method,
				"/users",
				map[string]string{"Content-Type": "application/json"},
				given.body,
			)

			assert.Equal(t, rec.Code, then.expectedStatus, "unexpected status code")

			if then.expectedErrorCode != "" {
				assert.ErrorCode(t, rec.Body.Bytes(), then.expectedErrorCode)
				return
			}

			if given.method == http.MethodGet {
				var response ListUsersResponse
				if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
					t.Fatalf("unmarshal list users response: %v", err)
				}

				assert.Equal(t, len(response.Users), then.expectedUserCount, "unexpected user count")
				assert.Equal(t, response.Users[0].DisplayName, then.expectedUserName, "unexpected display name")
				return
			}

			var response UserResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("unmarshal user response: %v", err)
			}

			assert.NotEmpty(t, response.UserID, "expected user id")
			assert.Equal(t, response.DisplayName, then.expectedUserName, "unexpected display name")
			assert.NotEmpty(t, response.CreatedAt, "expected created at")
			assert.NotEmpty(t, response.UpdatedAt, "expected updated at")
		})
	}
}

func TestUserHandlerSelectRoute(t *testing.T) {
	type Given struct {
		method       string
		body         string
		existingUser string
	}

	type Then struct {
		expectedStatus    int
		expectedErrorCode string
		expectedUserName  string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN existing user id " +
				"WHEN POST /users/select " +
				"THEN returns selected user",
			given: Given{
				method:       http.MethodPost,
				existingUser: "Kolja",
			},
			then: Then{
				expectedStatus:   http.StatusOK,
				expectedUserName: "Kolja",
			},
		},
		{
			name: "GIVEN missing user id " +
				"WHEN POST /users/select " +
				"THEN returns validation error",
			given: Given{
				method: http.MethodPost,
				body:   `{"userId":" "}`,
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: errorCodeMissingUserID,
			},
		},
		{
			name: "GIVEN unknown user id " +
				"WHEN POST /users/select " +
				"THEN returns not found",
			given: Given{
				method: http.MethodPost,
				body:   `{"userId":"missing-user"}`,
			},
			then: Then{
				expectedStatus:    http.StatusNotFound,
				expectedErrorCode: errorCodeUserNotFound,
			},
		},
		{
			name: "GIVEN invalid JSON " +
				"WHEN POST /users/select " +
				"THEN returns invalid JSON error",
			given: Given{
				method: http.MethodPost,
				body:   `{`,
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: network.ErrorCodeInvalidJSON,
			},
		},
		{
			name: "GIVEN unsupported method " +
				"WHEN GET /users/select " +
				"THEN returns method not allowed",
			given: Given{method: http.MethodGet},
			then: Then{
				expectedStatus:    http.StatusMethodNotAllowed,
				expectedErrorCode: network.ErrorCodeMethodNotAllowed,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			repo := user.NewInMemoryRepository()
			body := given.body

			if given.existingUser != "" {
				createdUser, err := repo.Create(t.Context(), given.existingUser)
				if err != nil {
					t.Fatalf("seed user: %v", err)
				}
				body = `{"userId":"` + createdUser.ID + `"}`
			}

			handler := NewUserHandler(repo)
			rec := tests.ExecuteRequest(
				http.HandlerFunc(handler.ServeUserSelectHTTP),
				given.method,
				"/users/select",
				map[string]string{"Content-Type": "application/json"},
				body,
			)

			assert.Equal(t, rec.Code, then.expectedStatus, "unexpected status code")

			if then.expectedErrorCode != "" {
				assert.ErrorCode(t, rec.Body.Bytes(), then.expectedErrorCode)
				return
			}

			var response UserResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("unmarshal user response: %v", err)
			}

			assert.NotEmpty(t, response.UserID, "expected user id")
			assert.Equal(t, response.DisplayName, then.expectedUserName, "unexpected display name")
		})
	}
}
