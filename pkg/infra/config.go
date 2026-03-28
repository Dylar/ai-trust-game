package infra

import (
	"context"
	"net/http"
)

type SimpleContextFunc func(context.Context) error

type Config struct {
	HTTP     []HTTPConfig
	Shutdown SimpleContextFunc
}

type HTTPConfig struct {
	Name     string
	Port     string
	Register func(*http.ServeMux)
	Shutdown SimpleContextFunc
}
