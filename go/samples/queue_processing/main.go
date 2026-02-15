package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"sync"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// MarketOrder represents a market order
type MarketOrder struct {
	OrderID   string  `bson:"order_id"`
	Symbol    string  `bson:"symbol"`
	Quantity  int     `bson:"quantity"`
	Price     float64 `bson:"price"`
	Side      string  `bson:"side"`
	OrderType string  `bson:"order_type"`
	Timestamp float64 `bson:"timestamp"`
}

// MongoDBQueueProcessor handles queue processing with MongoDB bulk inserts
type MongoDBQueueProcessor struct {
	client         *mongo.Client
	collection     *mongo.Collection
	queue          chan MarketOrder
	processedCount int
	errorCount     int
	totalTime      float64
	mu             sync.Mutex
}

// NewMongoDBQueueProcessor creates a new MongoDB queue processor
func NewMongoDBQueueProcessor(uri, dbName, collName string, queueSize int) (*MongoDBQueueProcessor, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, options.Client().ApplyURI(uri))
	if err != nil {
		return nil, err
	}

	collection := client.Database(dbName).Collection(collName)

	return &MongoDBQueueProcessor{
		client:     client,
		collection: collection,
		queue:      make(chan MarketOrder, queueSize),
	}, nil
}

// Enqueue adds an order to the queue
func (p *MongoDBQueueProcessor) Enqueue(order MarketOrder) {
	p.queue <- order
}

// BulkInsert performs bulk insert operation
func (p *MongoDBQueueProcessor) BulkInsert(orders []MarketOrder) error {
	if len(orders) == 0 {
		return nil
	}

	start := time.Now()
	ctx := context.Background()

	// Convert to interface slice for bulk insert
	docs := make([]interface{}, len(orders))
	for i, order := range orders {
		docs[i] = order
	}

	_, err := p.collection.InsertMany(ctx, docs, options.InsertMany().SetOrdered(false))

	elapsed := time.Since(start).Seconds()

	p.mu.Lock()
	p.totalTime += elapsed
	if err != nil {
		p.errorCount += len(orders)
	} else {
		p.processedCount += len(orders)
	}
	p.mu.Unlock()

	return err
}

// ProcessQueue processes the queue with adaptive batching
func (p *MongoDBQueueProcessor) ProcessQueue(batchSize, workers int, adaptive bool) {
	var wg sync.WaitGroup

	for i := 0; i < workers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()

			for {
				// Determine batch size
				currentBatchSize := batchSize
				if adaptive {
					queueSize := len(p.queue)
					if queueSize < 100 {
						currentBatchSize = 1
					} else if queueSize < 1000 {
						currentBatchSize = 100
					}
				}

				// Collect batch
				batch := make([]MarketOrder, 0, currentBatchSize)
				timeout := time.After(100 * time.Millisecond)

				for len(batch) < currentBatchSize {
					select {
					case order, ok := <-p.queue:
						if !ok {
							if len(batch) > 0 {
								p.BulkInsert(batch)
							}
							return
						}
						batch = append(batch, order)
					case <-timeout:
						if len(batch) > 0 {
							p.BulkInsert(batch)
							return
						}
						return
					}
				}

				if len(batch) > 0 {
					p.BulkInsert(batch)
				}
			}
		}()
	}

	wg.Wait()
}

// GetStats returns processing statistics
func (p *MongoDBQueueProcessor) GetStats() map[string]interface{} {
	p.mu.Lock()
	defer p.mu.Unlock()

	throughput := 0.0
	if p.totalTime > 0 {
		throughput = float64(p.processedCount) / p.totalTime
	}

	return map[string]interface{}{
		"processed_count":       p.processedCount,
		"error_count":           p.errorCount,
		"total_time_seconds":    p.totalTime,
		"throughput_per_second": throughput,
		"queue_size":            len(p.queue),
	}
}

// Close closes the database connection
func (p *MongoDBQueueProcessor) Close() error {
	close(p.queue)
	return p.client.Disconnect(context.Background())
}

// GenerateMarketOrder generates a random market order
func GenerateMarketOrder(id int, symbol string) MarketOrder {
	sides := []string{"BUY", "SELL"}
	return MarketOrder{
		OrderID:   fmt.Sprintf("ORD%010d", id),
		Symbol:    symbol,
		Quantity:  rand.Intn(1000) + 1,
		Price:     float64(rand.Intn(450)+50) + rand.Float64(),
		Side:      sides[rand.Intn(2)],
		OrderType: "MARKET",
		Timestamp: float64(time.Now().Unix()),
	}
}

func main() {
	fmt.Println("=== MongoDB Queue Processor Demo (Go) ===\n")

	// Initialize processor
	processor, err := NewMongoDBQueueProcessor(
		"mongodb://localhost:27017",
		"market_data",
		"orders",
		10000,
	)
	if err != nil {
		log.Fatalf("Failed to create processor: %v", err)
	}
	defer processor.Close()

	// Generate sample orders
	fmt.Println("Generating sample market orders...")
	symbols := []string{"AAPL", "GOOGL", "MSFT", "AMZN", "TSLA"}

	for i := 0; i < 5000; i++ {
		symbol := symbols[rand.Intn(len(symbols))]
		order := GenerateMarketOrder(i, symbol)
		processor.Enqueue(order)
	}

	fmt.Printf("Enqueued %d orders\n", 5000)

	// Process with adaptive batching
	fmt.Println("\nProcessing queue with adaptive batching...")
	start := time.Now()
	processor.ProcessQueue(1000, 4, true)

	// Display stats
	elapsed := time.Since(start).Seconds()
	fmt.Printf("\nProcessing completed in %.2f seconds\n", elapsed)
	fmt.Printf("Statistics: %+v\n", processor.GetStats())

	fmt.Println("\nDemo completed!")
}
