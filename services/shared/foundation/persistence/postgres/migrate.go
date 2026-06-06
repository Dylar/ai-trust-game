package postgres

import (
	"errors"
	"fmt"
	"path/filepath"
	"strings"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

var ErrMissingMigrationsPath = errors.New("missing postgres migrations path")

type MigrationConfig struct {
	DatabaseURL    string
	MigrationsPath string
}

func RunMigrations(cfg MigrationConfig) error {
	runner, err := newMigrator(cfg)
	if err != nil {
		return err
	}
	defer runner.Close()

	err = runner.Up()
	if errors.Is(err, migrate.ErrNoChange) {
		return nil
	}

	return err
}

func RollbackLastMigration(cfg MigrationConfig) error {
	runner, err := newMigrator(cfg)
	if err != nil {
		return err
	}
	defer runner.Close()

	err = runner.Steps(-1)
	if errors.Is(err, migrate.ErrNoChange) {
		return nil
	}

	return err
}

func FileSourceURL(path string) (string, error) {
	if path == "" {
		return "", ErrMissingMigrationsPath
	}
	if strings.HasPrefix(path, "file://") {
		return path, nil
	}

	absolutePath, err := filepath.Abs(path)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("file://%s", filepath.ToSlash(absolutePath)), nil
}

func newMigrator(cfg MigrationConfig) (*migrate.Migrate, error) {
	if cfg.DatabaseURL == "" {
		return nil, ErrMissingDatabaseURL
	}

	sourceURL, err := FileSourceURL(cfg.MigrationsPath)
	if err != nil {
		return nil, err
	}

	return migrate.New(sourceURL, cfg.DatabaseURL)
}
