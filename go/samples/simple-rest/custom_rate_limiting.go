///...server codes
///--- simple config
e.Use(middleware.RateLimiter(middleware.NewRateLimiterMemoryStore(20)))
///--- custom config.....
config := middleware.RateLimiterConfig{
    Skipper: middleware.DefaultSkipper,
    Store: middleware.NewRateLimiterMemoryStoreWithConfig(
        middleware.RateLimiterMemoryStoreConfig{Rate: 10, Burst: 30, ExpiresIn: 3 * time.Minute},
    ),
    IdentifierExtractor: func(ctx echo.Context) (string, error) {
        id := ctx.RealIP()
        return id, nil
    },
    ErrorHandler: func(context echo.Context, err error) error {
        return context.JSON(http.StatusForbidden, nil)
    },
    DenyHandler: func(context echo.Context, identifier string,err error) error {
        return context.JSON(http.StatusTooManyRequests, nil)
    },
}

e.Use(middleware.RateLimiterWithConfig(config))
///... remaining server code
