package main

import (
	"context"
	"crypto/rand"
	"encoding/binary"
	"fmt"
	"time"

	"github.com/labstack/echo/v4"
)

// contextKey is a custom type for context keys to avoid collisions
type contextKey string

const (
	traceContextKey contextKey = "trace"
)

// TraceContext holds tracing information
type TraceContext struct {
	TraceID   string
	SpanID    string
	ParentID  string
	StartTime time.Time
}

// TracingMiddleware creates a middleware for distributed tracing
func TracingMiddleware() echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			// Extract or generate trace ID
			traceID := c.Request().Header.Get("X-Trace-ID")
			if traceID == "" {
				traceID = generateTraceID()
			}

			// Generate span ID for this request
			spanID := generateSpanID()

			// Extract parent span ID if exists
			parentID := c.Request().Header.Get("X-Parent-Span-ID")

			// Create trace context
			trace := &TraceContext{
				TraceID:   traceID,
				SpanID:    spanID,
				ParentID:  parentID,
				StartTime: time.Now(),
			}

			// Store trace context in request context
			ctx := context.WithValue(c.Request().Context(), traceContextKey, trace)
			c.SetRequest(c.Request().WithContext(ctx))

			// Add trace headers to response
			c.Response().Header().Set("X-Trace-ID", traceID)
			c.Response().Header().Set("X-Span-ID", spanID)

			// Log trace information
			c.Logger().Infof("Starting request - TraceID: %s, SpanID: %s, ParentID: %s",
				traceID, spanID, parentID)

			// Process request
			err := next(c)

			// Log completion with duration
			duration := time.Since(trace.StartTime)
			c.Logger().Infof("Completed request - TraceID: %s, SpanID: %s, Duration: %v",
				traceID, spanID, duration)

			return err
		}
	}
}

// generateTraceID generates a unique trace ID
func generateTraceID() string {
	return fmt.Sprintf("trace-%d-%d", time.Now().UnixNano(), secureRandomInt())
}

// generateSpanID generates a unique span ID
func generateSpanID() string {
	return fmt.Sprintf("span-%d-%d", time.Now().UnixNano(), secureRandomInt())
}

// secureRandomInt generates a cryptographically secure random integer
func secureRandomInt() uint64 {
	var n uint64
	b := make([]byte, 8)
	_, err := rand.Read(b)
	if err != nil {
		// Fallback to timestamp-based randomness if crypto/rand fails
		return uint64(time.Now().UnixNano() % 100000)
	}
	n = binary.BigEndian.Uint64(b)
	return n
}

// GetTraceContext retrieves the trace context from the request context
func GetTraceContext(c echo.Context) *TraceContext {
	trace, ok := c.Request().Context().Value(traceContextKey).(*TraceContext)
	if !ok {
		return nil
	}
	return trace
}
