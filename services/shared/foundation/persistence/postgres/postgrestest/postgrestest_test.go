package postgrestest

import "testing"

func TestDatabaseURLReadsEnvironment(t *testing.T) {
	type Given struct {
		databaseURL string
	}

	type Then struct {
		expectedDatabaseURL string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN test database URL env " +
				"WHEN DatabaseURL is called " +
				"THEN returns configured test database URL",
			given: Given{databaseURL: "postgres://test"},
			then:  Then{expectedDatabaseURL: "postgres://test"},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			t.Setenv(DatabaseURLEnv, given.databaseURL)

			if DatabaseURL(t) != then.expectedDatabaseURL {
				t.Fatalf("expected database url %q", then.expectedDatabaseURL)
			}
		})
	}
}

func TestConfigReadsDatabaseURL(t *testing.T) {
	type Given struct {
		databaseURL string
	}

	type Then struct {
		expectedDatabaseURL string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN test database URL env " +
				"WHEN Config is called " +
				"THEN returns postgres config",
			given: Given{databaseURL: "postgres://test"},
			then:  Then{expectedDatabaseURL: "postgres://test"},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			t.Setenv(DatabaseURLEnv, given.databaseURL)

			cfg := Config(t)

			if cfg.DatabaseURL != then.expectedDatabaseURL {
				t.Fatalf("expected database url %q, got %q", then.expectedDatabaseURL, cfg.DatabaseURL)
			}
		})
	}
}
