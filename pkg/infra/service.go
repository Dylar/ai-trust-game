package infra

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"
)

type Server struct {
	httpServers []*HTTPServer
	shutdown    SimpleContextFunc
}

func NewServer(cfg Config) *Server {
	httpServers := make([]*HTTPServer, 0, len(cfg.HTTP))

	for _, httpCfg := range cfg.HTTP {
		httpServers = append(httpServers, NewHTTPServer(httpCfg))
	}

	return &Server{
		httpServers: httpServers,
		shutdown:    cfg.Shutdown,
	}
}

func (srv *Server) Run() error {
	serverErrCh := make(chan error, len(srv.httpServers))

	for _, server := range srv.httpServers {
		httpSrv := server
		go func() {
			serverErrCh <- httpSrv.Run()
		}()
	}

	signalCtx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	select {
	case err := <-serverErrCh:
		if err != nil {
			return err
		}
	case <-signalCtx.Done():
		fmt.Println("shutdown signal received")
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	return srv.Shutdown(shutdownCtx)
}

func (srv *Server) Shutdown(ctx context.Context) error {
	var wg sync.WaitGroup
	errCh := make(chan error, len(srv.httpServers)+1)

	for _, server := range srv.httpServers {
		wg.Add(1)
		go func(srv *HTTPServer) {
			defer wg.Done()
			err := srv.Shutdown(ctx)
			if err != nil {
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

	fmt.Println("application stopped cleanly")
	return nil
}
