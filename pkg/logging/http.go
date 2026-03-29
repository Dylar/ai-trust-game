package logging

import (
	"net/http"
	"time"
)

type statusRecorder struct {
	http.ResponseWriter
	statusCode int
}

func newStatusRecorder(w http.ResponseWriter) *statusRecorder {
	return &statusRecorder{
		ResponseWriter: w,
		statusCode:     http.StatusOK,
	}
}

func (r *statusRecorder) WriteHeader(statusCode int) {
	r.statusCode = statusCode
	r.ResponseWriter.WriteHeader(statusCode)
}

func (r *statusRecorder) Write(data []byte) (int, error) {
	return r.ResponseWriter.Write(data)
}

func HttpLogging(logger Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			recorder := newStatusRecorder(w)
			next.ServeHTTP(recorder, r)
			duration := time.Since(start)
			logger.Info(
				r.Context(),
				"http request completed",
				WithField("method", r.Method),
				WithField("path", r.URL.Path),
				WithField("status", recorder.statusCode),
				WithField("duration_ms", duration.Milliseconds()),
			)
		})
	}
}
