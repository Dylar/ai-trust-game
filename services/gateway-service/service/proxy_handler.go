package service

import (
	"net/http"
	"net/http/httputil"
	"net/url"
	"strings"

	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
)

type ProxyHandler struct {
	proxy *httputil.ReverseProxy
}

func NewProxyHandler(target string) (*ProxyHandler, error) {
	targetURL, err := url.Parse(target)
	if err != nil || targetURL.Scheme == "" || targetURL.Host == "" {
		return nil, errInvalidBackendURL
	}

	proxy := httputil.NewSingleHostReverseProxy(targetURL)
	originalDirector := proxy.Director
	proxy.Director = func(req *http.Request) {
		originalDirector(req)
		req.Host = targetURL.Host
		forwardRequestMetadata(req)
	}
	proxy.ErrorHandler = func(w http.ResponseWriter, _ *http.Request, _ error) {
		network.WriteJSONError(w, http.StatusBadGateway, network.ErrorCodeInternal)
	}

	return &ProxyHandler{proxy: proxy}, nil
}

func (handler *ProxyHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	handler.proxy.ServeHTTP(w, req)
}

func forwardRequestMetadata(req *http.Request) {
	meta := network.GetMetadata(req.Context())

	if meta.RequestID != "" {
		req.Header.Set(network.RequestIDHeader, meta.RequestID)
	}
	if meta.SessionID != "" {
		req.Header.Set(network.SessionIDHeader, meta.SessionID)
	}
	if meta.UserID != "" {
		req.Header.Set(network.UserIDHeader, meta.UserID)
	}

	req.Header.Set("X-Forwarded-Proto", forwardedProto(req))
}

func forwardedProto(req *http.Request) string {
	if proto := strings.TrimSpace(req.Header.Get("X-Forwarded-Proto")); proto != "" {
		return proto
	}
	if req.TLS != nil {
		return "https"
	}
	return "http"
}
