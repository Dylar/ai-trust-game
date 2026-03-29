package infra

import (
	"context"
	"errors"
	"net/http"
	"time"
)

const DefaultPort = "8080"

type HTTPServer struct {
	httpServer *http.Server
	shutdown   SimpleContextFunc
}

func NewHTTPServer(cfg HTTPConfig) *HTTPServer {
	mux := http.NewServeMux()

	if cfg.Register != nil {
		cfg.Register(mux)
	}

	return &HTTPServer{
		httpServer: &http.Server{
			Addr:              ":" + cfg.Port,
			Handler:           mux,
			ReadHeaderTimeout: 5 * time.Second,
		},
		shutdown: cfg.Shutdown,
	}
}

func (srv *HTTPServer) Run() error {
	err := srv.httpServer.ListenAndServe()
	if err != nil && !errors.Is(err, http.ErrServerClosed) {
		return err
	}

	return nil
}

func (srv *HTTPServer) Shutdown(ctx context.Context) error {
	if srv.shutdown != nil {
		err := srv.shutdown(ctx)
		if err != nil {
			return err
		}
	}

	return srv.httpServer.Shutdown(ctx)
}
