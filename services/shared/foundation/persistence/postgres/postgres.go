package postgres

import (
	"context"
	"database/sql"
	"errors"
	"os"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
)

const (
	DefaultDriverName = "pgx"
	DatabaseURLEnv    = "DATABASE_URL"
	DriverNameEnv     = "DATABASE_DRIVER"
)

var (
	ErrMissingDatabaseURL = errors.New("missing postgres database url")
	ErrNilDatabase        = errors.New("nil postgres database")
)

type Config struct {
	DatabaseURL     string
	DriverName      string
	MaxOpenConns    int
	MaxIdleConns    int
	ConnMaxLifetime time.Duration
}

func ConfigFromEnv() Config {
	return Config{
		DatabaseURL: os.Getenv(DatabaseURLEnv),
		DriverName:  os.Getenv(DriverNameEnv),
	}
}

func Open(ctx context.Context, cfg Config) (*sql.DB, error) {
	if cfg.DatabaseURL == "" {
		return nil, ErrMissingDatabaseURL
	}

	db, err := sql.Open(driverName(cfg), cfg.DatabaseURL)
	if err != nil {
		return nil, err
	}

	applyPoolSettings(db, cfg)

	if err := Ping(ctx, db); err != nil {
		_ = db.Close()
		return nil, err
	}

	return db, nil
}

func Ping(ctx context.Context, db *sql.DB) error {
	if db == nil {
		return ErrNilDatabase
	}

	return db.PingContext(ctx)
}

func driverName(cfg Config) string {
	if cfg.DriverName != "" {
		return cfg.DriverName
	}

	return DefaultDriverName
}

func applyPoolSettings(db *sql.DB, cfg Config) {
	if cfg.MaxOpenConns > 0 {
		db.SetMaxOpenConns(cfg.MaxOpenConns)
	}
	if cfg.MaxIdleConns > 0 {
		db.SetMaxIdleConns(cfg.MaxIdleConns)
	}
	if cfg.ConnMaxLifetime > 0 {
		db.SetConnMaxLifetime(cfg.ConnMaxLifetime)
	}
}
