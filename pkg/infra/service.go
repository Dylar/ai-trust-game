package infra

import (
	"context"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"
)

type Server struct {
	logger      logging.Logger
	httpServers []*HTTPServer
	shutdown    SimpleContextFunc
}

func NewServer(logger logging.Logger, cfg Config) *Server {
	httpServers := make([]*HTTPServer, 0, len(cfg.HTTP))

	for _, httpCfg := range cfg.HTTP {
		httpServers = append(httpServers, NewHTTPServer(httpCfg))
	}

	return &Server{
		logger:      logger,
		httpServers: httpServers,
		shutdown:    cfg.Shutdown,
	}
}

func (srv *Server) Run() error {
	ctx := context.Background()
	srv.logger.Info(ctx, "server starting")
	serverErrCh := make(chan error, len(srv.httpServers))

	for _, server := range srv.httpServers {
		go func(server *HTTPServer) {
			serverErrCh <- server.Run()
		}(server)
	}

	signalCtx, stop := signal.NotifyContext(ctx, os.Interrupt, syscall.SIGTERM)
	defer stop()

	select {
	case err := <-serverErrCh:
		if err != nil {
			srv.logger.Error(ctx, "server runtime stopped due to error", logging.WithError(err))
			return err
		}
	case <-signalCtx.Done():
		srv.logger.Info(ctx, "shutdown signal received")
	}

	shutdownCtx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	return srv.Shutdown(shutdownCtx)
}

func (srv *Server) Shutdown(ctx context.Context) error {
	srv.logger.Info(context.Background(), "server shutdown starting")
	var wg sync.WaitGroup
	errCh := make(chan error, len(srv.httpServers)+1)

	for _, server := range srv.httpServers {
		wg.Add(1)
		go func(server *HTTPServer) {
			defer wg.Done()
			err := server.Shutdown(ctx)
			if err != nil {
				srv.logger.Error(ctx, "http server shutdown failed", logging.WithError(err))
				errCh <- err
			}
		}(server)
	}

	if srv.shutdown != nil {
		wg.Add(1)
		go func() {
			defer wg.Done()
			err := srv.shutdown(ctx)
			if err != nil {
				srv.logger.Error(ctx, "shutdown failed", logging.WithError(err))
				errCh <- err
			}
		}()
	}

	wg.Wait()
	close(errCh)

	for err := range errCh {
		if err != nil {
			return err
		}
	}

	srv.logger.Info(ctx, "server shutdown complete")
	return nil
}
