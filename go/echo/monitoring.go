package main

import (
	"net/http"
	"strconv"
	"time"

	"github.com/labstack/echo/v4"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

// Prometheus metrics
var (
	httpRequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"method", "endpoint", "status"},
	)

	httpRequestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "HTTP request duration in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"method", "endpoint"},
	)

	httpRequestSize = promauto.NewSummaryVec(
		prometheus.SummaryOpts{
			Name: "http_request_size_bytes",
			Help: "HTTP request size in bytes",
		},
		[]string{"method", "endpoint"},
	)

	httpResponseSize = promauto.NewSummaryVec(
		prometheus.SummaryOpts{
			Name: "http_response_size_bytes",
			Help: "HTTP response size in bytes",
		},
		[]string{"method", "endpoint"},
	)

	activeRequests = promauto.NewGauge(
		prometheus.GaugeOpts{
			Name: "http_requests_active",
			Help: "Number of HTTP requests currently being processed",
		},
	)
)

// PrometheusMiddleware creates a middleware for Prometheus metrics collection
func PrometheusMiddleware() echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			start := time.Now()

			// Increment active requests
			activeRequests.Inc()
			defer activeRequests.Dec()

			// Get request size
			reqSize := computeRequestSize(c.Request())

			// Process request
			err := next(c)

			// Calculate duration
			duration := time.Since(start).Seconds()

			// Get response status
			status := c.Response().Status
			if err != nil {
				if httpErr, ok := err.(*echo.HTTPError); ok {
					status = httpErr.Code
				} else {
					status = 500
				}
			}

			// Record metrics
			method := c.Request().Method
			path := c.Path() // Use route pattern instead of actual path
			if path == "" {
				path = c.Request().URL.Path
			}

			httpRequestsTotal.WithLabelValues(method, path, strconv.Itoa(status)).Inc()
			httpRequestDuration.WithLabelValues(method, path).Observe(duration)
			httpRequestSize.WithLabelValues(method, path).Observe(float64(reqSize))
			httpResponseSize.WithLabelValues(method, path).Observe(float64(c.Response().Size))

			return err
		}
	}
}

// computeRequestSize computes the approximate size of a request
func computeRequestSize(r *http.Request) int {
	size := 0
	if r.ContentLength != -1 {
		size = int(r.ContentLength)
	}
	return size
}
