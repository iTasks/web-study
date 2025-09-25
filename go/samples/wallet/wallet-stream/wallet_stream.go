package main

import (
	"context"
	"fmt"
	"github.com/labstack/echo-contrib/prometheus"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"io"
	"net/http"
	"os"
	"os/signal"
	"time"
	. "wallet-stream/config"
)

func main() {
	e := echo.New()
	p := prometheus.NewPrometheus("echo", nil)
	p.Use(e)
	e.Use(middleware.Recover())
	go func() {
		port := os.Getenv("PORT")
		if port == "" {
			port = HostConfig.Port
		}
		if err := e.Start(fmt.Sprintf(":%s", port)); err != nil && err != http.ErrServerClosed {
			e.Logger.Fatal("Shutting down the server")
		}
	}()
	//todo: need to add stream consumer here
	http.Handle("/", e)
	graceFullShutdown(e, nil)
}

func graceFullShutdown(e *echo.Echo, c io.Closer) {
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt)
	<-quit
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	_ = c.Close()
	if err := e.Shutdown(ctx); err != nil {
		e.Logger.Fatal(err)
	}
}
