package main

import (
	"time"

	"gorm.io/gorm"
)

// User represents a user in the system
// Note: validate tags are included for documentation and future use with validation libraries
type User struct {
	ID        uint           `gorm:"primarykey" json:"id"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
	Name      string         `gorm:"size:255;not null" json:"name" validate:"required"`
	Email     string         `gorm:"size:255;uniqueIndex;not null" json:"email" validate:"required,email"`
	Role      string         `gorm:"size:50;default:user" json:"role"`
	Active    bool           `gorm:"default:true" json:"active"`
}

// TableName specifies the table name for User model
func (User) TableName() string {
	return "users"
}

// Product represents a product in the system
// Note: validate tags are included for documentation and future use with validation libraries
type Product struct {
	ID          uint           `gorm:"primarykey" json:"id"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
	Name        string         `gorm:"size:255;not null" json:"name" validate:"required"`
	Description string         `gorm:"type:text" json:"description"`
	Price       float64        `gorm:"not null" json:"price" validate:"required,gt=0"`
	Stock       int            `gorm:"not null;default:0" json:"stock"`
	SKU         string         `gorm:"size:100;uniqueIndex" json:"sku"`
}

// TableName specifies the table name for Product model
func (Product) TableName() string {
	return "products"
}
