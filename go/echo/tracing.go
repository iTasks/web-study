package main

import (
	"context"
	"fmt"
	"time"

	"github.com/labstack/echo/v4"
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
			ctx := context.WithValue(c.Request().Context(), "trace", trace)
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
	return fmt.Sprintf("trace-%d-%d", time.Now().UnixNano(), randomInt())
}

// generateSpanID generates a unique span ID
func generateSpanID() string {
	return fmt.Sprintf("span-%d-%d", time.Now().UnixNano(), randomInt())
}

// randomInt generates a random integer for ID generation
func randomInt() int {
	return int(time.Now().UnixNano() % 100000)
}

// GetTraceContext retrieves the trace context from the request context
func GetTraceContext(c echo.Context) *TraceContext {
	trace, ok := c.Request().Context().Value("trace").(*TraceContext)
	if !ok {
		return nil
	}
	return trace
}
