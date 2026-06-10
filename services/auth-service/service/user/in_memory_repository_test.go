package user

import (
	"errors"
	"testing"
)

func TestInMemoryRepository(t *testing.T) {
	type Given struct {
		existingUsers []string
		createName    string
		getID         string
	}

	type Then struct {
		expectedCreateError error
		expectedListCount   int
		expectedFound       bool
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN empty repository " +
				"WHEN Create is called " +
				"THEN stores user",
			given: Given{createName: "Kolja"},
			then: Then{
				expectedListCount: 1,
				expectedFound:     true,
			},
		},
		{
			name: "GIVEN duplicate display name " +
				"WHEN Create is called " +
				"THEN returns ErrDuplicateDisplayName",
			given: Given{
				existingUsers: []string{"Kolja"},
				createName:    "Kolja",
			},
			then: Then{
				expectedCreateError: ErrDuplicateDisplayName,
				expectedListCount:   1,
			},
		},
		{
			name: "GIVEN missing user id " +
				"WHEN Get is called " +
				"THEN reports not found",
			given: Given{getID: "missing-user"},
			then:  Then{expectedFound: false},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			repo := NewInMemoryRepository()
			for _, displayName := range given.existingUsers {
				if _, err := repo.Create(t.Context(), displayName); err != nil {
					t.Fatalf("seed user: %v", err)
				}
			}

			getID := given.getID
			if given.createName != "" {
				createdUser, err := repo.Create(t.Context(), given.createName)
				if !errors.Is(err, then.expectedCreateError) {
					t.Fatalf("expected create error %v, got %v", then.expectedCreateError, err)
				}
				if err == nil {
					getID = createdUser.ID
				}
			}

			users, err := repo.List(t.Context())
			if err != nil {
				t.Fatalf("list users: %v", err)
			}
			if len(users) != then.expectedListCount {
				t.Fatalf("expected %d users, got %d", then.expectedListCount, len(users))
			}

			if getID != "" {
				_, found, err := repo.Get(t.Context(), getID)
				if err != nil {
					t.Fatalf("get user: %v", err)
				}
				if found != then.expectedFound {
					t.Fatalf("expected found %t, got %t", then.expectedFound, found)
				}
			}
		})
	}
}
