package network

import "net/http"

const (
	accessControlAllowHeaders = "Access-Control-Allow-Headers"
	accessControlAllowMethods = "Access-Control-Allow-Methods"
	accessControlAllowOrigin  = "Access-Control-Allow-Origin"
	accessControlExposeHeader = "Access-Control-Expose-Headers"
)

func CORSMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set(accessControlAllowOrigin, "*")
		w.Header().Set(accessControlAllowMethods, "GET, POST, OPTIONS")
		w.Header().Set(accessControlAllowHeaders, "Content-Type, X-Session-Id, X-User-Id")
		w.Header().Set(accessControlExposeHeader, RequestIDHeader)

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}
