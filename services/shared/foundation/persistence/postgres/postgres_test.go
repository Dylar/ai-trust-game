package postgres

import (
	"context"
	"database/sql"
	"errors"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

func TestConfigFromEnv(t *testing.T) {
	type Given struct {
		databaseURL string
		driverName  string
	}

	type Then struct {
		expectedDatabaseURL string
		expectedDriverName  string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN database env values " +
				"WHEN ConfigFromEnv is called " +
				"THEN returns postgres config",
			given: Given{
				databaseURL: "postgres://example",
				driverName:  "custom",
			},
			then: Then{
				expectedDatabaseURL: "postgres://example",
				expectedDriverName:  "custom",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			t.Setenv(DatabaseURLEnv, given.databaseURL)
			t.Setenv(DriverNameEnv, given.driverName)

			cfg := ConfigFromEnv()

			if cfg.DatabaseURL != then.expectedDatabaseURL {
				t.Fatalf("expected database url %q, got %q", then.expectedDatabaseURL, cfg.DatabaseURL)
			}
			if cfg.DriverName != then.expectedDriverName {
				t.Fatalf("expected driver name %q, got %q", then.expectedDriverName, cfg.DriverName)
			}
		})
	}
}

func TestOpenValidation(t *testing.T) {
	type Given struct {
		cfg Config
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
			name: "GIVEN config without database URL " +
				"WHEN Open is called " +
				"THEN returns ErrMissingDatabaseURL",
			given: Given{cfg: Config{}},
			then:  Then{expectedError: ErrMissingDatabaseURL},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			_, err := Open(context.Background(), given.cfg)

			if !errors.Is(err, then.expectedError) {
				t.Fatalf("expected error %v, got %v", then.expectedError, err)
			}
		})
	}
}

func TestOpenPingsDatabase(t *testing.T) {
	db, mock, err := sqlmock.NewWithDSN("open_ping", sqlmock.MonitorPingsOption(true))
	if err != nil {
		t.Fatalf("create sql mock: %v", err)
	}
	defer db.Close()

	mock.ExpectPing()

	opened, err := Open(context.Background(), Config{
		DatabaseURL: "open_ping",
		DriverName:  "sqlmock",
	})
	if err != nil {
		t.Fatalf("expected open success, got %v", err)
	}
	defer opened.Close()

	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("unmet expectations: %v", err)
	}
}

func TestPingSucceeds(t *testing.T) {
	db, mock, err := sqlmock.New(sqlmock.MonitorPingsOption(true))
	if err != nil {
		t.Fatalf("create sql mock: %v", err)
	}
	defer db.Close()

	mock.ExpectPing()

	if err := Ping(context.Background(), db); err != nil {
		t.Fatalf("expected ping success, got %v", err)
	}

	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("unmet expectations: %v", err)
	}
}

func TestPingValidation(t *testing.T) {
	type Given struct {
		db *sql.DB
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
			name: "GIVEN nil database " +
				"WHEN Ping is called " +
				"THEN returns ErrNilDatabase",
			given: Given{db: nil},
			then:  Then{expectedError: ErrNilDatabase},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			err := Ping(context.Background(), given.db)

			if !errors.Is(err, then.expectedError) {
				t.Fatalf("expected error %v, got %v", then.expectedError, err)
			}
		})
	}
}

func TestDriverName(t *testing.T) {
	type Given struct {
		cfg Config
	}

	type Then struct {
		expectedDriverName string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN no configured driver " +
				"WHEN driverName is called " +
				"THEN returns the default pgx driver",
			given: Given{cfg: Config{}},
			then:  Then{expectedDriverName: DefaultDriverName},
		},
		{
			name: "GIVEN configured driver " +
				"WHEN driverName is called " +
				"THEN returns the configured driver",
			given: Given{cfg: Config{DriverName: "custom"}},
			then:  Then{expectedDriverName: "custom"},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			actual := driverName(given.cfg)

			if actual != then.expectedDriverName {
				t.Fatalf("expected driver name %q, got %q", then.expectedDriverName, actual)
			}
		})
	}
}

func TestApplyPoolSettings(t *testing.T) {
	db, err := sql.Open(DefaultDriverName, "postgres://example")
	if err != nil {
		t.Fatalf("open db handle: %v", err)
	}
	defer db.Close()

	applyPoolSettings(db, Config{
		MaxOpenConns: 2,
		MaxIdleConns: 1,
	})

	stats := db.Stats()
	if stats.MaxOpenConnections != 2 {
		t.Fatalf("expected max open connections 2, got %d", stats.MaxOpenConnections)
	}
}
