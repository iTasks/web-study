package main

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
	// Create Echo instance
	e := echo.New()

	// Hide banner for cleaner production logs
	e.HideBanner = true

	// ============================================
	// Production-Ready Middlewares Stack
	// ============================================

	// 1. Request ID - Must be first to generate ID for all subsequent middlewares
	e.Use(middleware.RequestID())

	// 2. Tracing - For distributed tracing support
	e.Use(TracingMiddleware())

	// 3. Prometheus Metrics - Collect metrics for all requests
	e.Use(PrometheusMiddleware())

	// 4. Structured Logger - Log all requests with trace and request IDs
	e.Use(middleware.LoggerWithConfig(middleware.LoggerConfig{
		Format: `{"time":"${time_rfc3339}","id":"${id}","remote_ip":"${remote_ip}",` +
			`"host":"${host}","method":"${method}","uri":"${uri}","user_agent":"${user_agent}",` +
			`"status":${status},"error":"${error}","latency_ms":${latency_ms},"bytes_in":${bytes_in},` +
			`"bytes_out":${bytes_out}}` + "\n",
		CustomTimeFormat: "2006-01-02 15:04:05.000",
	}))

	// 5. Recover - Must be early to catch panics from other middlewares
	e.Use(middleware.RecoverWithConfig(middleware.RecoverConfig{
		StackSize: 1 << 10, // 1 KB
		LogLevel:  2,       // ERROR level
	}))

	// 6. Security Headers
	e.Use(middleware.SecureWithConfig(middleware.SecureConfig{
		XSSProtection:         "1; mode=block",
		ContentTypeNosniff:    "nosniff",
		XFrameOptions:         "SAMEORIGIN",
		HSTSMaxAge:            31536000,
		ContentSecurityPolicy: "default-src 'self'",
	}))

	// 7. CORS
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins:  []string{"*"}, // Configure based on your needs
		AllowMethods:  []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch},
		AllowHeaders:  []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept, echo.HeaderAuthorization, "X-Trace-ID", "X-Parent-Span-ID"},
		ExposeHeaders: []string{"X-Trace-ID", "X-Span-ID"},
	}))

	// 8. Gzip Compression
	e.Use(middleware.GzipWithConfig(middleware.GzipConfig{
		Level: 5,
	}))

	// 9. Rate Limiting
	e.Use(middleware.RateLimiter(middleware.NewRateLimiterMemoryStore(100)))

	// 10. Request Timeout
	e.Use(middleware.TimeoutWithConfig(middleware.TimeoutConfig{
		Timeout: 30 * time.Second,
	}))

	// ============================================
	// Observability Endpoints
	// ============================================

	// Health check endpoint (Kubernetes liveness probe)
	e.GET("/health", healthCheckHandler)
	e.GET("/healthz", healthCheckHandler) // Kubernetes compatibility alias

	// Readiness check endpoint (Kubernetes readiness probe)
	e.GET("/ready", readinessCheckHandler)
	e.GET("/readyz", readinessCheckHandler) // Kubernetes compatibility alias

	// Prometheus metrics endpoint
	e.GET("/metrics", echo.WrapHandler(promhttp.Handler()))

	// System info endpoint
	e.GET("/info", systemInfoHandler)

	// ============================================
	// Application Routes
	// ============================================

	// API v1 routes
	v1 := e.Group("/api/v1")

	// Users endpoints
	v1.GET("/users", getUsersHandler)
	v1.POST("/users", createUserHandler)
	v1.GET("/users/:id", getUserHandler)
	v1.PUT("/users/:id", updateUserHandler)
	v1.DELETE("/users/:id", deleteUserHandler)

	// Example endpoints for testing observability features
	v1.GET("/slow", slowHandler)          // Test timeout and latency tracking
	v1.GET("/error", errorHandler)        // Test error handling
	v1.GET("/panic", panicHandler)        // Test panic recovery
	v1.GET("/trace", traceExampleHandler) // Test distributed tracing

	// ============================================
	// Graceful Shutdown
	// ============================================

	// Start server in a goroutine
	go func() {
		e.Logger.Info("Server starting on :8080")
		if err := e.Start(":8080"); err != nil && err != http.ErrServerClosed {
			e.Logger.Fatal("shutting down the server")
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt)
	<-quit

	e.Logger.Info("Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := e.Shutdown(ctx); err != nil {
		e.Logger.Fatal(err)
	}

	e.Logger.Info("Server stopped gracefully")
}

// ============================================
// Handler Functions
// ============================================

func healthCheckHandler(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]interface{}{
		"status": "healthy",
		"time":   time.Now().Format(time.RFC3339),
	})
}

func readinessCheckHandler(c echo.Context) error {
	// In production, check:
	// - Database connectivity
	// - Cache availability
	// - External service dependencies
	return c.JSON(http.StatusOK, map[string]interface{}{
		"status": "ready",
		"checks": map[string]string{
			"database": "ok",
			"cache":    "ok",
		},
		"time": time.Now().Format(time.RFC3339),
	})
}

func systemInfoHandler(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]interface{}{
		"version":     "1.0.0",
		"environment": getEnv("ENVIRONMENT", "development"),
		"uptime":      time.Now().Format(time.RFC3339),
	})
}

func getUsersHandler(c echo.Context) error {
	users := []map[string]interface{}{
		{"id": 1, "name": "John Doe", "email": "john@example.com", "role": "admin"},
		{"id": 2, "name": "Jane Smith", "email": "jane@example.com", "role": "user"},
		{"id": 3, "name": "Bob Johnson", "email": "bob@example.com", "role": "user"},
	}
	return c.JSON(http.StatusOK, map[string]interface{}{
		"data":  users,
		"count": len(users),
	})
}

func createUserHandler(c echo.Context) error {
	var user map[string]interface{}
	if err := c.Bind(&user); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
	}

	// Validate required fields
	if user["name"] == nil || user["email"] == nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "name and email are required",
		})
	}

	// Simulate user creation
	user["id"] = 4
	user["created_at"] = time.Now().Format(time.RFC3339)

	return c.JSON(http.StatusCreated, user)
}

func getUserHandler(c echo.Context) error {
	id := c.Param("id")
	user := map[string]interface{}{
		"id":    id,
		"name":  "John Doe",
		"email": "john@example.com",
		"role":  "admin",
	}
	return c.JSON(http.StatusOK, user)
}

func updateUserHandler(c echo.Context) error {
	id := c.Param("id")
	var updates map[string]interface{}
	if err := c.Bind(&updates); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
	}

	updates["id"] = id
	updates["updated_at"] = time.Now().Format(time.RFC3339)

	return c.JSON(http.StatusOK, updates)
}

func deleteUserHandler(c echo.Context) error {
	id := c.Param("id")
	return c.JSON(http.StatusOK, map[string]interface{}{
		"message": "User deleted successfully",
		"id":      id,
	})
}

func slowHandler(c echo.Context) error {
	// Simulate slow operation
	time.Sleep(2 * time.Second)
	return c.JSON(http.StatusOK, map[string]string{
		"message": "This was a slow operation",
	})
}

func errorHandler(c echo.Context) error {
	return echo.NewHTTPError(http.StatusInternalServerError, "Something went wrong")
}

func panicHandler(c echo.Context) error {
	panic("This is a deliberate panic to test recovery middleware!")
}

func traceExampleHandler(c echo.Context) error {
	trace := GetTraceContext(c)
	if trace == nil {
		return c.JSON(http.StatusOK, map[string]string{
			"message": "No trace context available",
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"message":    "Trace information",
		"trace_id":   trace.TraceID,
		"span_id":    trace.SpanID,
		"parent_id":  trace.ParentID,
		"start_time": trace.StartTime.Format(time.RFC3339),
		"duration":   time.Since(trace.StartTime).String(),
	})
}

// ============================================
// Utility Functions
// ============================================

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
