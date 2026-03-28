package setup

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"time"
)

const DefaultPort = "8080"

type HTTPServer struct {
	name       string
	httpServer *http.Server
	shutdown   SimpleContextFunc
}

func NewHTTPServer(cfg HTTPConfig) *HTTPServer {
	mux := http.NewServeMux()

	if cfg.Register != nil {
		cfg.Register(mux)
	}

	return &HTTPServer{
		name: cfg.Name,
		httpServer: &http.Server{
			Addr:              ":" + cfg.Port,
			Handler:           mux,
			ReadHeaderTimeout: 5 * time.Second,
		},
		shutdown: cfg.Shutdown,
	}
}

func (s *HTTPServer) Run() error {
	fmt.Printf("%s listening on %s", s.name, s.httpServer.Addr)

	err := s.httpServer.ListenAndServe()
	if err != nil && !errors.Is(err, http.ErrServerClosed) {
		return err
	}

	return nil
}

func (s *HTTPServer) Shutdown(ctx context.Context) error {
	if s.shutdown != nil {
		err := s.shutdown(ctx)
		if err != nil {
			return err
		}
	}

	return s.httpServer.Shutdown(ctx)
}
