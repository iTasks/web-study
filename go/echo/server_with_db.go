//go:build dbserver
// +build dbserver

package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"time"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var dbManager *DBManager

func main() {
	// Initialize database
	dbConfig := DatabaseConfig{
		Driver: getEnv("DB_DRIVER", "sqlite"),
		DBName: getEnv("DB_NAME", "echo_server.db"),
		Host:   getEnv("DB_HOST", "localhost"),
		Port:   getEnv("DB_PORT", "5432"),
		User:   getEnv("DB_USER", "postgres"),
		Password: getEnv("DB_PASSWORD", ""),
		SSLMode: getEnv("DB_SSLMODE", "disable"),
	}

	var err error
	dbManager, err = NewDBManager(dbConfig)
	if err != nil {
		panic(fmt.Sprintf("Failed to initialize database: %v", err))
	}
	defer dbManager.Close()

	// Run migrations
	if err := dbManager.AutoMigrate(); err != nil {
		panic(fmt.Sprintf("Failed to run migrations: %v", err))
	}

	// Seed data if requested
	if getEnv("DB_SEED", "true") == "true" {
		if err := dbManager.SeedData(); err != nil {
			fmt.Printf("Warning: Failed to seed database: %v\n", err)
		}
	}

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
		AllowOrigins: []string{"*"}, // Configure based on your needs
		AllowMethods: []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch},
		AllowHeaders: []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept, echo.HeaderAuthorization, "X-Trace-ID", "X-Parent-Span-ID"},
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

	// Users endpoints (with database)
	v1.GET("/users", listUsersHandler)
	v1.POST("/users", createUserHandler)
	v1.GET("/users/:id", getUserHandler)
	v1.PUT("/users/:id", updateUserHandler)
	v1.DELETE("/users/:id", deleteUserHandler)

	// Products endpoints (with database)
	v1.GET("/products", listProductsHandler)
	v1.POST("/products", createProductHandler)
	v1.GET("/products/:id", getProductHandler)
	v1.PUT("/products/:id", updateProductHandler)
	v1.DELETE("/products/:id", deleteProductHandler)

	// Database endpoints
	v1.GET("/db/stats", dbStatsHandler)
	v1.GET("/db/performance", dbPerformanceHandler)

	// Example endpoints for testing observability features
	v1.GET("/slow", slowHandler)           // Test timeout and latency tracking
	v1.GET("/error", errorHandler)         // Test error handling
	v1.GET("/panic", panicHandler)         // Test panic recovery
	v1.GET("/trace", traceExampleHandler)  // Test distributed tracing

	// ============================================
	// Graceful Shutdown
	// ============================================

	// Start server in a goroutine
	go func() {
		port := getEnv("PORT", "8080")
		e.Logger.Infof("Server starting on :%s", port)
		if err := e.Start(":" + port); err != nil && err != http.ErrServerClosed {
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
	// Check database connection
	sqlDB, err := dbManager.DB.DB()
	dbStatus := "ok"
	if err != nil || sqlDB.Ping() != nil {
		dbStatus = "error"
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"status": "ready",
		"checks": map[string]string{
			"database": dbStatus,
		},
		"time": time.Now().Format(time.RFC3339),
	})
}

func systemInfoHandler(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]interface{}{
		"version":     "1.0.0",
		"environment": getEnv("ENVIRONMENT", "development"),
		"database":    dbManager.Config.Driver,
		"uptime":      time.Now().Format(time.RFC3339),
	})
}

// User Handlers
func listUsersHandler(c echo.Context) error {
	var users []User
	if err := dbManager.DB.Find(&users).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to fetch users",
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"data":  users,
		"count": len(users),
	})
}

func createUserHandler(c echo.Context) error {
	var user User
	if err := c.Bind(&user); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
	}

	if user.Name == "" || user.Email == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "name and email are required",
		})
	}

	if err := dbManager.DB.Create(&user).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to create user",
		})
	}

	return c.JSON(http.StatusCreated, user)
}

func getUserHandler(c echo.Context) error {
	id := c.Param("id")
	var user User
	
	if err := dbManager.DB.First(&user, id).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{
			"error": "User not found",
		})
	}

	return c.JSON(http.StatusOK, user)
}

func updateUserHandler(c echo.Context) error {
	id := c.Param("id")
	var user User
	
	if err := dbManager.DB.First(&user, id).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{
			"error": "User not found",
		})
	}

	var updates User
	if err := c.Bind(&updates); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
	}

	if err := dbManager.DB.Model(&user).Updates(updates).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to update user",
		})
	}

	return c.JSON(http.StatusOK, user)
}

func deleteUserHandler(c echo.Context) error {
	id := c.Param("id")
	
	if err := dbManager.DB.Delete(&User{}, id).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to delete user",
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"message": "User deleted successfully",
		"id":      id,
	})
}

// Product Handlers
func listProductsHandler(c echo.Context) error {
	var products []Product
	if err := dbManager.DB.Find(&products).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to fetch products",
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"data":  products,
		"count": len(products),
	})
}

func createProductHandler(c echo.Context) error {
	var product Product
	if err := c.Bind(&product); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
	}

	if product.Name == "" || product.Price <= 0 {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "name and valid price are required",
		})
	}

	if err := dbManager.DB.Create(&product).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to create product",
		})
	}

	return c.JSON(http.StatusCreated, product)
}

func getProductHandler(c echo.Context) error {
	id := c.Param("id")
	var product Product
	
	if err := dbManager.DB.First(&product, id).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{
			"error": "Product not found",
		})
	}

	return c.JSON(http.StatusOK, product)
}

func updateProductHandler(c echo.Context) error {
	id := c.Param("id")
	var product Product
	
	if err := dbManager.DB.First(&product, id).Error; err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{
			"error": "Product not found",
		})
	}

	var updates Product
	if err := c.Bind(&updates); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "Invalid request body",
		})
	}

	if err := dbManager.DB.Model(&product).Updates(updates).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to update product",
		})
	}

	return c.JSON(http.StatusOK, product)
}

func deleteProductHandler(c echo.Context) error {
	id := c.Param("id")
	
	if err := dbManager.DB.Delete(&Product{}, id).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to delete product",
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"message": "Product deleted successfully",
		"id":      id,
	})
}

// Database Handlers
func dbStatsHandler(c echo.Context) error {
	stats, err := dbManager.GetDatabaseStats()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to get database statistics",
		})
	}

	return c.JSON(http.StatusOK, stats)
}

func dbPerformanceHandler(c echo.Context) error {
	analysis, err := dbManager.AnalyzePerformance()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "Failed to analyze performance",
		})
	}

	return c.JSON(http.StatusOK, analysis)
}

// Testing Handlers
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

func getIntEnv(key string, defaultValue int) int {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	intVal, err := strconv.Atoi(value)
	if err != nil {
		return defaultValue
	}
	return intVal
}
