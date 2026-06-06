package migrations

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestMigrationsHaveUpAndDownPairs(t *testing.T) {
	files, err := filepath.Glob("*.sql")
	if err != nil {
		t.Fatalf("glob migrations: %v", err)
	}
	if len(files) == 0 {
		t.Fatal("expected migration files")
	}

	up := make(map[string]bool)
	down := make(map[string]bool)

	for _, file := range files {
		switch {
		case strings.HasSuffix(file, ".up.sql"):
			up[strings.TrimSuffix(file, ".up.sql")] = true
		case strings.HasSuffix(file, ".down.sql"):
			down[strings.TrimSuffix(file, ".down.sql")] = true
		default:
			t.Fatalf("migration file %q must end with .up.sql or .down.sql", file)
		}
	}

	for version := range up {
		if !down[version] {
			t.Fatalf("missing down migration for %s", version)
		}
	}
	for version := range down {
		if !up[version] {
			t.Fatalf("missing up migration for %s", version)
		}
	}
}

func TestInitialMigrationCreatesExpectedTables(t *testing.T) {
	content, err := os.ReadFile("000001_initial_persistence.up.sql")
	if err != nil {
		t.Fatalf("read initial migration: %v", err)
	}

	type Given struct {
		table string
	}

	type Then struct {
		expectedSQL string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	sql := string(content)
	scenarios := []Scenario{
		{given: Given{table: "users"}},
		{given: Given{table: "sessions"}},
		{given: Given{table: "interactions"}},
		{given: Given{table: "audit_events"}},
		{given: Given{table: "client_logs"}},
	}

	for index := range scenarios {
		table := scenarios[index].given.table
		scenarios[index].name = "GIVEN initial persistence migration " +
			"WHEN migration is inspected " +
			"THEN creates " + table + " table"
		scenarios[index].then.expectedSQL = "CREATE TABLE " + table
	}

	for _, scenario := range scenarios {
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			if !strings.Contains(sql, then.expectedSQL) {
				t.Fatalf("expected initial migration to contain %q", then.expectedSQL)
			}
		})
	}
}
