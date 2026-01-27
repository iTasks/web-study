package main

import (
	"fmt"
	"log"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// DatabaseConfig holds database configuration
type DatabaseConfig struct {
	Driver   string
	Host     string
	Port     string
	User     string
	Password string
	DBName   string
	SSLMode  string
}

// DBManager handles database operations
type DBManager struct {
	DB     *gorm.DB
	Config DatabaseConfig
}

// NewDBManager creates a new database manager
func NewDBManager(config DatabaseConfig) (*DBManager, error) {
	var db *gorm.DB
	var err error

	// Configure GORM logger
	gormConfig := &gorm.Config{
		Logger: logger.New(
			log.New(os.Stdout, "\r\n", log.LstdFlags),
			logger.Config{
				SlowThreshold:             time.Second,
				LogLevel:                  logger.Info,
				IgnoreRecordNotFoundError: true,
				Colorful:                  true,
			},
		),
		NowFunc: func() time.Time {
			return time.Now().UTC()
		},
	}

	switch config.Driver {
	case "sqlite":
		db, err = gorm.Open(sqlite.Open(config.DBName), gormConfig)
	case "postgres":
		dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
			config.Host, config.User, config.Password, config.DBName, config.Port, config.SSLMode)
		db, err = gorm.Open(postgres.Open(dsn), gormConfig)
	default:
		return nil, fmt.Errorf("unsupported database driver: %s", config.Driver)
	}

	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	// Get underlying SQL DB for connection pool settings
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get database instance: %w", err)
	}

	// Set connection pool settings
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(time.Hour)

	return &DBManager{
		DB:     db,
		Config: config,
	}, nil
}

// AutoMigrate runs database migrations
func (dm *DBManager) AutoMigrate() error {
	log.Println("Running database migrations...")
	
	err := dm.DB.AutoMigrate(
		&User{},
		&Product{},
	)
	
	if err != nil {
		return fmt.Errorf("failed to run migrations: %w", err)
	}
	
	log.Println("Database migrations completed successfully")
	return nil
}

// SeedData populates the database with sample data
func (dm *DBManager) SeedData() error {
	log.Println("Seeding database with sample data...")

	// Check if data already exists
	var userCount int64
	dm.DB.Model(&User{}).Count(&userCount)
	
	if userCount > 0 {
		log.Println("Database already contains data, skipping seed")
		return nil
	}

	// Seed users
	users := []User{
		{Name: "John Doe", Email: "john@example.com", Role: "admin", Active: true},
		{Name: "Jane Smith", Email: "jane@example.com", Role: "user", Active: true},
		{Name: "Bob Johnson", Email: "bob@example.com", Role: "user", Active: true},
		{Name: "Alice Williams", Email: "alice@example.com", Role: "moderator", Active: true},
	}

	if err := dm.DB.Create(&users).Error; err != nil {
		return fmt.Errorf("failed to seed users: %w", err)
	}

	// Seed products
	products := []Product{
		{Name: "Laptop", Description: "High-performance laptop", Price: 999.99, Stock: 50, SKU: "LAP-001"},
		{Name: "Mouse", Description: "Wireless mouse", Price: 29.99, Stock: 200, SKU: "MOU-001"},
		{Name: "Keyboard", Description: "Mechanical keyboard", Price: 79.99, Stock: 100, SKU: "KEY-001"},
		{Name: "Monitor", Description: "27-inch 4K monitor", Price: 399.99, Stock: 30, SKU: "MON-001"},
		{Name: "Headphones", Description: "Noise-cancelling headphones", Price: 149.99, Stock: 75, SKU: "HEA-001"},
	}

	if err := dm.DB.Create(&products).Error; err != nil {
		return fmt.Errorf("failed to seed products: %w", err)
	}

	log.Println("Database seeding completed successfully")
	return nil
}

// GetDatabaseStats returns database statistics
func (dm *DBManager) GetDatabaseStats() (map[string]interface{}, error) {
	stats := make(map[string]interface{})

	// Get user count
	var userCount int64
	if err := dm.DB.Model(&User{}).Count(&userCount).Error; err != nil {
		return nil, err
	}
	stats["total_users"] = userCount

	// Get active user count
	var activeUserCount int64
	if err := dm.DB.Model(&User{}).Where("active = ?", true).Count(&activeUserCount).Error; err != nil {
		return nil, err
	}
	stats["active_users"] = activeUserCount

	// Get product count
	var productCount int64
	if err := dm.DB.Model(&Product{}).Count(&productCount).Error; err != nil {
		return nil, err
	}
	stats["total_products"] = productCount

	// Get low stock products
	var lowStockCount int64
	if err := dm.DB.Model(&Product{}).Where("stock < ?", 50).Count(&lowStockCount).Error; err != nil {
		return nil, err
	}
	stats["low_stock_products"] = lowStockCount

	// Get connection pool stats
	sqlDB, err := dm.DB.DB()
	if err == nil {
		dbStats := sqlDB.Stats()
		stats["max_open_connections"] = dbStats.MaxOpenConnections
		stats["open_connections"] = dbStats.OpenConnections
		stats["in_use"] = dbStats.InUse
		stats["idle"] = dbStats.Idle
	}

	return stats, nil
}

// AnalyzePerformance performs database performance analysis
func (dm *DBManager) AnalyzePerformance() (map[string]interface{}, error) {
	analysis := make(map[string]interface{})

	// Query performance test - Users
	start := time.Now()
	var users []User
	if err := dm.DB.Find(&users).Error; err != nil {
		return nil, err
	}
	analysis["users_query_time_ms"] = time.Since(start).Milliseconds()

	// Query performance test - Products
	start = time.Now()
	var products []Product
	if err := dm.DB.Find(&products).Error; err != nil {
		return nil, err
	}
	analysis["products_query_time_ms"] = time.Since(start).Milliseconds()

	// Complex query performance test
	start = time.Now()
	var activeUsers []User
	if err := dm.DB.Where("active = ?", true).Order("created_at DESC").Limit(10).Find(&activeUsers).Error; err != nil {
		return nil, err
	}
	analysis["complex_query_time_ms"] = time.Since(start).Milliseconds()

	// Index check (table sizes)
	analysis["users_count"] = len(users)
	analysis["products_count"] = len(products)

	return analysis, nil
}

// Close closes the database connection
func (dm *DBManager) Close() error {
	sqlDB, err := dm.DB.DB()
	if err != nil {
		return err
	}
	return sqlDB.Close()
}
