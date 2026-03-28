package logging

import (
	"fmt"
	"net/http"
	"time"
)

func HttpLogging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		duration := time.Since(start)
		// TODO make real logging instead of printing
		fmt.Printf("method=%s path=%s duration=%s\n", r.Method, r.URL.Path, duration)
	})
}
