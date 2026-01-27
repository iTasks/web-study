package main

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
)

func TestHealthCheckHandler(t *testing.T) {
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	if assert.NoError(t, healthCheckHandler(c)) {
		assert.Equal(t, http.StatusOK, rec.Code)
		assert.Contains(t, rec.Body.String(), "healthy")
	}
}

func TestReadinessCheckHandler(t *testing.T) {
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/ready", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	if assert.NoError(t, readinessCheckHandler(c)) {
		assert.Equal(t, http.StatusOK, rec.Code)
		assert.Contains(t, rec.Body.String(), "ready")
	}
}

func TestGetUsersHandler(t *testing.T) {
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/users", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	if assert.NoError(t, getUsersHandler(c)) {
		assert.Equal(t, http.StatusOK, rec.Code)
		assert.Contains(t, rec.Body.String(), "John Doe")
		assert.Contains(t, rec.Body.String(), "Jane Smith")
	}
}

func TestCreateUserHandler(t *testing.T) {
	e := echo.New()
	userJSON := `{"name":"Test User","email":"test@example.com"}`
	req := httptest.NewRequest(http.MethodPost, "/api/v1/users", strings.NewReader(userJSON))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	if assert.NoError(t, createUserHandler(c)) {
		assert.Equal(t, http.StatusCreated, rec.Code)
		assert.Contains(t, rec.Body.String(), "Test User")
		assert.Contains(t, rec.Body.String(), "test@example.com")
	}
}

func TestCreateUserHandlerInvalidJSON(t *testing.T) {
	e := echo.New()
	req := httptest.NewRequest(http.MethodPost, "/api/v1/users", strings.NewReader("invalid json"))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	// Invalid JSON should result in an error when trying to bind
	// Or a bad request when missing required fields
	err := createUserHandler(c)
	if err == nil {
		// If binding doesn't fail, check for validation error
		assert.Equal(t, http.StatusBadRequest, rec.Code)
	} else {
		assert.Error(t, err)
	}
}

func TestGetUserHandler(t *testing.T) {
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/users/1", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetParamNames("id")
	c.SetParamValues("1")

	if assert.NoError(t, getUserHandler(c)) {
		assert.Equal(t, http.StatusOK, rec.Code)
		assert.Contains(t, rec.Body.String(), "John Doe")
	}
}

func TestErrorHandler(t *testing.T) {
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/error", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	err := errorHandler(c)
	assert.Error(t, err)

	httpErr, ok := err.(*echo.HTTPError)
	assert.True(t, ok)
	assert.Equal(t, http.StatusInternalServerError, httpErr.Code)
}

func TestTracingMiddleware(t *testing.T) {
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	handler := TracingMiddleware()(func(c echo.Context) error {
		trace := GetTraceContext(c)
		assert.NotNil(t, trace)
		assert.NotEmpty(t, trace.TraceID)
		assert.NotEmpty(t, trace.SpanID)
		return c.String(http.StatusOK, "OK")
	})

	err := handler(c)
	assert.NoError(t, err)
	assert.NotEmpty(t, rec.Header().Get("X-Trace-ID"))
	assert.NotEmpty(t, rec.Header().Get("X-Span-ID"))
}

func TestTracingMiddlewareWithExistingTraceID(t *testing.T) {
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	req.Header.Set("X-Trace-ID", "existing-trace-id")
	req.Header.Set("X-Parent-Span-ID", "parent-span-id")
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	handler := TracingMiddleware()(func(c echo.Context) error {
		trace := GetTraceContext(c)
		assert.NotNil(t, trace)
		assert.Equal(t, "existing-trace-id", trace.TraceID)
		assert.Equal(t, "parent-span-id", trace.ParentID)
		return c.String(http.StatusOK, "OK")
	})

	err := handler(c)
	assert.NoError(t, err)
	assert.Equal(t, "existing-trace-id", rec.Header().Get("X-Trace-ID"))
}

func TestPrometheusMiddleware(t *testing.T) {
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/test", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)

	handler := PrometheusMiddleware()(func(c echo.Context) error {
		return c.String(http.StatusOK, "OK")
	})

	err := handler(c)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, rec.Code)
}

func TestGenerateTraceID(t *testing.T) {
	id1 := generateTraceID()
	id2 := generateTraceID()

	assert.NotEmpty(t, id1)
	assert.NotEmpty(t, id2)
	assert.NotEqual(t, id1, id2) // Should generate unique IDs
	assert.Contains(t, id1, "trace-")
}

func TestGenerateSpanID(t *testing.T) {
	id1 := generateSpanID()
	id2 := generateSpanID()

	assert.NotEmpty(t, id1)
	assert.NotEmpty(t, id2)
	assert.NotEqual(t, id1, id2) // Should generate unique IDs
	assert.Contains(t, id1, "span-")
}

func BenchmarkHealthCheckHandler(b *testing.B) {
	e := echo.New()
	req := httptest.NewRequest(http.MethodGet, "/health", nil)

	for i := 0; i < b.N; i++ {
		rec := httptest.NewRecorder()
		c := e.NewContext(req, rec)
		healthCheckHandler(c)
	}
}

func BenchmarkTracingMiddleware(b *testing.B) {
	e := echo.New()
	handler := TracingMiddleware()(func(c echo.Context) error {
		return c.String(http.StatusOK, "OK")
	})

	for i := 0; i < b.N; i++ {
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		rec := httptest.NewRecorder()
		c := e.NewContext(req, rec)
		handler(c)
	}
}

// Example test demonstrating the full middleware stack
func TestFullMiddlewareStack(t *testing.T) {
	e := echo.New()
	e.Use(TracingMiddleware())
	e.Use(PrometheusMiddleware())

	e.GET("/test", func(c echo.Context) error {
		trace := GetTraceContext(c)
		return c.JSON(http.StatusOK, map[string]string{
			"trace_id": trace.TraceID,
			"span_id":  trace.SpanID,
		})
	})

	req := httptest.NewRequest(http.MethodGet, "/test", nil)
	rec := httptest.NewRecorder()

	e.ServeHTTP(rec, req)

	assert.Equal(t, http.StatusOK, rec.Code)
	assert.NotEmpty(t, rec.Header().Get("X-Trace-ID"))
	assert.NotEmpty(t, rec.Header().Get("X-Span-ID"))
	assert.Contains(t, rec.Body.String(), "trace_id")
}

func ExampleTracingMiddleware() {
	e := echo.New()
	e.Use(TracingMiddleware())

	e.GET("/example", func(c echo.Context) error {
		trace := GetTraceContext(c)
		return c.JSON(http.StatusOK, map[string]string{
			"trace_id": trace.TraceID,
		})
	})

	fmt.Println("Tracing middleware configured")
	// Output: Tracing middleware configured
}
