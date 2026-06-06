package postgrestest

import (
	"context"
	"database/sql"
	"os"
	"testing"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/persistence/postgres"
)

const DatabaseURLEnv = "TEST_DATABASE_URL"

func Config(t testing.TB) postgres.Config {
	t.Helper()

	return postgres.Config{
		DatabaseURL: DatabaseURL(t),
	}
}

func DatabaseURL(t testing.TB) string {
	t.Helper()

	databaseURL := os.Getenv(DatabaseURLEnv)
	if databaseURL == "" {
		t.Skipf("set %s to run PostgreSQL-backed repository tests", DatabaseURLEnv)
	}

	return databaseURL
}

func Open(t testing.TB) *sql.DB {
	t.Helper()

	db, err := postgres.Open(context.Background(), Config(t))
	if err != nil {
		t.Fatalf("open test postgres database: %v", err)
	}

	t.Cleanup(func() {
		if err := db.Close(); err != nil {
			t.Fatalf("close test postgres database: %v", err)
		}
	})

	return db
}
