package postgres

import (
	"errors"
	"path/filepath"
	"strings"
	"testing"
)

func TestFileSourceURL(t *testing.T) {
	type Given struct {
		path string
	}

	type Then struct {
		expectedError  error
		expectedURL    string
		expectedPrefix string
		expectedSuffix string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN empty migrations path " +
				"WHEN FileSourceURL is called " +
				"THEN returns ErrMissingMigrationsPath",
			given: Given{path: ""},
			then:  Then{expectedError: ErrMissingMigrationsPath},
		},
		{
			name: "GIVEN existing file URL " +
				"WHEN FileSourceURL is called " +
				"THEN keeps the source URL unchanged",
			given: Given{path: "file:///tmp/migrations"},
			then:  Then{expectedURL: "file:///tmp/migrations"},
		},
		{
			name: "GIVEN relative path " +
				"WHEN FileSourceURL is called " +
				"THEN returns an absolute file source URL",
			given: Given{path: "migrations"},
			then: Then{
				expectedPrefix: "file://",
				expectedSuffix: filepath.ToSlash(filepath.Join("migrations")),
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			sourceURL, err := FileSourceURL(given.path)

			if then.expectedError != nil {
				if !errors.Is(err, then.expectedError) {
					t.Fatalf("expected error %v, got %v", then.expectedError, err)
				}
				return
			}

			if err != nil {
				t.Fatalf("expected no error, got %v", err)
			}
			if then.expectedURL != "" && sourceURL != then.expectedURL {
				t.Fatalf("expected source url %q, got %q", then.expectedURL, sourceURL)
			}
			if then.expectedPrefix != "" && !strings.HasPrefix(sourceURL, then.expectedPrefix) {
				t.Fatalf("expected source url prefix %q, got %q", then.expectedPrefix, sourceURL)
			}
			if then.expectedSuffix != "" && !strings.HasSuffix(sourceURL, then.expectedSuffix) {
				t.Fatalf("expected source url suffix %q, got %q", then.expectedSuffix, sourceURL)
			}
		})
	}
}

func TestNewMigratorValidation(t *testing.T) {
	type Given struct {
		cfg MigrationConfig
	}

	type Then struct {
		expectedError error
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN missing database URL " +
				"WHEN newMigrator is called " +
				"THEN returns ErrMissingDatabaseURL",
			given: Given{cfg: MigrationConfig{MigrationsPath: "migrations"}},
			then:  Then{expectedError: ErrMissingDatabaseURL},
		},
		{
			name: "GIVEN missing migrations path " +
				"WHEN newMigrator is called " +
				"THEN returns ErrMissingMigrationsPath",
			given: Given{cfg: MigrationConfig{DatabaseURL: "postgres://example"}},
			then:  Then{expectedError: ErrMissingMigrationsPath},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			_, err := newMigrator(given.cfg)

			if !errors.Is(err, then.expectedError) {
				t.Fatalf("expected error %v, got %v", then.expectedError, err)
			}
		})
	}
}

func TestMigrationRunnerValidation(t *testing.T) {
	type Given struct {
		run func(MigrationConfig) error
		cfg MigrationConfig
	}

	type Then struct {
		expectedError error
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN empty config " +
				"WHEN RunMigrations is called " +
				"THEN returns ErrMissingDatabaseURL",
			given: Given{run: RunMigrations, cfg: MigrationConfig{}},
			then:  Then{expectedError: ErrMissingDatabaseURL},
		},
		{
			name: "GIVEN empty config " +
				"WHEN RollbackLastMigration is called " +
				"THEN returns ErrMissingDatabaseURL",
			given: Given{run: RollbackLastMigration, cfg: MigrationConfig{}},
			then:  Then{expectedError: ErrMissingDatabaseURL},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			err := given.run(given.cfg)

			if !errors.Is(err, then.expectedError) {
				t.Fatalf("expected error %v, got %v", then.expectedError, err)
			}
		})
	}
}
