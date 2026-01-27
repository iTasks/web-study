package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

// CLIClient represents the CLI client
type CLIClient struct {
	BaseURL string
	Client  *http.Client
}

// NewCLIClient creates a new CLI client
func NewCLIClient(baseURL string) *CLIClient {
	return &CLIClient{
		BaseURL: baseURL,
		Client: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// Main CLI menu
func (c *CLIClient) ShowMenu() {
	reader := bufio.NewReader(os.Stdin)

	for {
		fmt.Println("\n╔═══════════════════════════════════════════╗")
		fmt.Println("║   Echo Server CLI - Main Menu            ║")
		fmt.Println("╚═══════════════════════════════════════════╝")
		fmt.Println()
		fmt.Println("  [1] Health & Status Checks")
		fmt.Println("  [2] User Management (CRUD)")
		fmt.Println("  [3] Product Management (CRUD)")
		fmt.Println("  [4] Metrics & Monitoring")
		fmt.Println("  [5] Database Analysis")
		fmt.Println("  [6] Server Logs")
		fmt.Println("  [7] Performance Testing")
		fmt.Println("  [0] Exit")
		fmt.Println()
		fmt.Print("Select an option: ")

		choice, _ := reader.ReadString('\n')
		choice = strings.TrimSpace(choice)

		switch choice {
		case "1":
			c.healthMenu(reader)
		case "2":
			c.userMenu(reader)
		case "3":
			c.productMenu(reader)
		case "4":
			c.metricsMenu(reader)
		case "5":
			c.databaseAnalysisMenu(reader)
		case "6":
			c.logsMenu(reader)
		case "7":
			c.performanceMenu(reader)
		case "0":
			fmt.Println("\nGoodbye!")
			return
		default:
			fmt.Println("\n❌ Invalid option. Please try again.")
		}
	}
}

// Health Menu
func (c *CLIClient) healthMenu(reader *bufio.Reader) {
	for {
		fmt.Println("\n╔═══════════════════════════════════════════╗")
		fmt.Println("║   Health & Status Checks                 ║")
		fmt.Println("╚═══════════════════════════════════════════╝")
		fmt.Println()
		fmt.Println("  [1] Check Health")
		fmt.Println("  [2] Check Readiness")
		fmt.Println("  [3] System Info")
		fmt.Println("  [4] All Checks")
		fmt.Println("  [0] Back to Main Menu")
		fmt.Println()
		fmt.Print("Select an option: ")

		choice, _ := reader.ReadString('\n')
		choice = strings.TrimSpace(choice)

		switch choice {
		case "1":
			c.checkEndpoint("/health", "Health Check")
		case "2":
			c.checkEndpoint("/ready", "Readiness Check")
		case "3":
			c.checkEndpoint("/info", "System Info")
		case "4":
			c.checkEndpoint("/health", "Health Check")
			c.checkEndpoint("/ready", "Readiness Check")
			c.checkEndpoint("/info", "System Info")
		case "0":
			return
		default:
			fmt.Println("\n❌ Invalid option.")
		}
	}
}

// User Menu
func (c *CLIClient) userMenu(reader *bufio.Reader) {
	for {
		fmt.Println("\n╔═══════════════════════════════════════════╗")
		fmt.Println("║   User Management (CRUD)                 ║")
		fmt.Println("╚═══════════════════════════════════════════╝")
		fmt.Println()
		fmt.Println("  [1] List All Users")
		fmt.Println("  [2] Get User by ID")
		fmt.Println("  [3] Create New User")
		fmt.Println("  [4] Update User")
		fmt.Println("  [5] Delete User")
		fmt.Println("  [0] Back to Main Menu")
		fmt.Println()
		fmt.Print("Select an option: ")

		choice, _ := reader.ReadString('\n')
		choice = strings.TrimSpace(choice)

		switch choice {
		case "1":
			c.checkEndpoint("/api/v1/users", "List Users")
		case "2":
			fmt.Print("Enter User ID: ")
			id, _ := reader.ReadString('\n')
			id = strings.TrimSpace(id)
			c.checkEndpoint("/api/v1/users/"+id, "Get User")
		case "3":
			c.createUser(reader)
		case "4":
			c.updateUser(reader)
		case "5":
			c.deleteUser(reader)
		case "0":
			return
		default:
			fmt.Println("\n❌ Invalid option.")
		}
	}
}

// Product Menu
func (c *CLIClient) productMenu(reader *bufio.Reader) {
	for {
		fmt.Println("\n╔═══════════════════════════════════════════╗")
		fmt.Println("║   Product Management (CRUD)              ║")
		fmt.Println("╚═══════════════════════════════════════════╝")
		fmt.Println()
		fmt.Println("  [1] List All Products")
		fmt.Println("  [2] Get Product by ID")
		fmt.Println("  [3] Create New Product")
		fmt.Println("  [4] Update Product")
		fmt.Println("  [5] Delete Product")
		fmt.Println("  [0] Back to Main Menu")
		fmt.Println()
		fmt.Print("Select an option: ")

		choice, _ := reader.ReadString('\n')
		choice = strings.TrimSpace(choice)

		switch choice {
		case "1":
			c.checkEndpoint("/api/v1/products", "List Products")
		case "2":
			fmt.Print("Enter Product ID: ")
			id, _ := reader.ReadString('\n')
			id = strings.TrimSpace(id)
			c.checkEndpoint("/api/v1/products/"+id, "Get Product")
		case "3":
			c.createProduct(reader)
		case "4":
			c.updateProduct(reader)
		case "5":
			c.deleteProduct(reader)
		case "0":
			return
		default:
			fmt.Println("\n❌ Invalid option.")
		}
	}
}

// Metrics Menu
func (c *CLIClient) metricsMenu(reader *bufio.Reader) {
	for {
		fmt.Println("\n╔═══════════════════════════════════════════╗")
		fmt.Println("║   Metrics & Monitoring                   ║")
		fmt.Println("╚═══════════════════════════════════════════╝")
		fmt.Println()
		fmt.Println("  [1] View Prometheus Metrics")
		fmt.Println("  [2] View HTTP Request Metrics")
		fmt.Println("  [3] View Active Requests")
		fmt.Println("  [0] Back to Main Menu")
		fmt.Println()
		fmt.Print("Select an option: ")

		choice, _ := reader.ReadString('\n')
		choice = strings.TrimSpace(choice)

		switch choice {
		case "1":
			c.viewMetrics()
		case "2":
			c.viewHTTPMetrics()
		case "3":
			c.viewActiveRequests()
		case "0":
			return
		default:
			fmt.Println("\n❌ Invalid option.")
		}
	}
}

// Database Analysis Menu
func (c *CLIClient) databaseAnalysisMenu(reader *bufio.Reader) {
	for {
		fmt.Println("\n╔═══════════════════════════════════════════╗")
		fmt.Println("║   Database Analysis                      ║")
		fmt.Println("╚═══════════════════════════════════════════╝")
		fmt.Println()
		fmt.Println("  [1] Database Statistics")
		fmt.Println("  [2] Performance Analysis")
		fmt.Println("  [3] Connection Pool Status")
		fmt.Println("  [0] Back to Main Menu")
		fmt.Println()
		fmt.Print("Select an option: ")

		choice, _ := reader.ReadString('\n')
		choice = strings.TrimSpace(choice)

		switch choice {
		case "1":
			c.checkEndpoint("/api/v1/db/stats", "Database Statistics")
		case "2":
			c.checkEndpoint("/api/v1/db/performance", "Performance Analysis")
		case "3":
			c.checkEndpoint("/api/v1/db/stats", "Connection Pool Status")
		case "0":
			return
		default:
			fmt.Println("\n❌ Invalid option.")
		}
	}
}

// Logs Menu
func (c *CLIClient) logsMenu(reader *bufio.Reader) {
	fmt.Println("\n╔═══════════════════════════════════════════╗")
	fmt.Println("║   Server Logs                            ║")
	fmt.Println("╚═══════════════════════════════════════════╝")
	fmt.Println()
	fmt.Println("  Note: Server logs are output in JSON format to stdout.")
	fmt.Println("  To view logs, check the server console or log files.")
	fmt.Println()
	fmt.Print("Press Enter to continue...")
	reader.ReadString('\n')
}

// Performance Menu
func (c *CLIClient) performanceMenu(reader *bufio.Reader) {
	for {
		fmt.Println("\n╔═══════════════════════════════════════════╗")
		fmt.Println("║   Performance Testing                    ║")
		fmt.Println("╚═══════════════════════════════════════════╝")
		fmt.Println()
		fmt.Println("  [1] Test Slow Endpoint (2s delay)")
		fmt.Println("  [2] Test Error Handling")
		fmt.Println("  [3] Test Panic Recovery")
		fmt.Println("  [4] Test Tracing")
		fmt.Println("  [0] Back to Main Menu")
		fmt.Println()
		fmt.Print("Select an option: ")

		choice, _ := reader.ReadString('\n')
		choice = strings.TrimSpace(choice)

		switch choice {
		case "1":
			c.checkEndpoint("/api/v1/slow", "Slow Endpoint Test")
		case "2":
			c.checkEndpoint("/api/v1/error", "Error Handling Test")
		case "3":
			c.checkEndpoint("/api/v1/panic", "Panic Recovery Test")
		case "4":
			c.checkEndpoint("/api/v1/trace", "Tracing Test")
		case "0":
			return
		default:
			fmt.Println("\n❌ Invalid option.")
		}
	}
}

// Helper methods
func (c *CLIClient) checkEndpoint(path, title string) {
	fmt.Printf("\n⏳ Checking %s...\n", title)
	
	resp, err := c.Client.Get(c.BaseURL + path)
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("❌ Error reading response: %v\n", err)
		return
	}

	fmt.Printf("\n✅ Status: %s (%d)\n", resp.Status, resp.StatusCode)
	
	// Pretty print JSON
	var prettyJSON map[string]interface{}
	if err := json.Unmarshal(body, &prettyJSON); err == nil {
		formatted, _ := json.MarshalIndent(prettyJSON, "", "  ")
		fmt.Printf("Response:\n%s\n", string(formatted))
	} else {
		// If not JSON, print first 500 chars
		if len(body) > 500 {
			fmt.Printf("Response:\n%s...\n", string(body[:500]))
		} else {
			fmt.Printf("Response:\n%s\n", string(body))
		}
	}
}

func (c *CLIClient) createUser(reader *bufio.Reader) {
	fmt.Println("\n--- Create New User ---")
	fmt.Print("Name: ")
	name, _ := reader.ReadString('\n')
	name = strings.TrimSpace(name)
	
	fmt.Print("Email: ")
	email, _ := reader.ReadString('\n')
	email = strings.TrimSpace(email)
	
	fmt.Print("Role (admin/user/moderator): ")
	role, _ := reader.ReadString('\n')
	role = strings.TrimSpace(role)

	payload := fmt.Sprintf(`{"name":"%s","email":"%s","role":"%s"}`, name, email, role)
	c.postRequest("/api/v1/users", payload, "Create User")
}

func (c *CLIClient) updateUser(reader *bufio.Reader) {
	fmt.Print("\nEnter User ID: ")
	id, _ := reader.ReadString('\n')
	id = strings.TrimSpace(id)
	
	fmt.Print("New Name (or leave empty): ")
	name, _ := reader.ReadString('\n')
	name = strings.TrimSpace(name)
	
	payload := fmt.Sprintf(`{"name":"%s"}`, name)
	c.putRequest("/api/v1/users/"+id, payload, "Update User")
}

func (c *CLIClient) deleteUser(reader *bufio.Reader) {
	fmt.Print("\nEnter User ID to delete: ")
	id, _ := reader.ReadString('\n')
	id = strings.TrimSpace(id)
	
	c.deleteRequest("/api/v1/users/"+id, "Delete User")
}

func (c *CLIClient) createProduct(reader *bufio.Reader) {
	fmt.Println("\n--- Create New Product ---")
	fmt.Print("Name: ")
	name, _ := reader.ReadString('\n')
	name = strings.TrimSpace(name)
	
	fmt.Print("Description: ")
	desc, _ := reader.ReadString('\n')
	desc = strings.TrimSpace(desc)
	
	fmt.Print("Price: ")
	price, _ := reader.ReadString('\n')
	price = strings.TrimSpace(price)
	
	fmt.Print("Stock: ")
	stock, _ := reader.ReadString('\n')
	stock = strings.TrimSpace(stock)

	payload := fmt.Sprintf(`{"name":"%s","description":"%s","price":%s,"stock":%s}`, name, desc, price, stock)
	c.postRequest("/api/v1/products", payload, "Create Product")
}

func (c *CLIClient) updateProduct(reader *bufio.Reader) {
	fmt.Print("\nEnter Product ID: ")
	id, _ := reader.ReadString('\n')
	id = strings.TrimSpace(id)
	
	fmt.Print("New Price (or 0 to skip): ")
	price, _ := reader.ReadString('\n')
	price = strings.TrimSpace(price)
	
	payload := fmt.Sprintf(`{"price":%s}`, price)
	c.putRequest("/api/v1/products/"+id, payload, "Update Product")
}

func (c *CLIClient) deleteProduct(reader *bufio.Reader) {
	fmt.Print("\nEnter Product ID to delete: ")
	id, _ := reader.ReadString('\n')
	id = strings.TrimSpace(id)
	
	c.deleteRequest("/api/v1/products/"+id, "Delete Product")
}

func (c *CLIClient) postRequest(path, payload, title string) {
	fmt.Printf("\n⏳ %s...\n", title)
	
	req, err := http.NewRequest("POST", c.BaseURL+path, strings.NewReader(payload))
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		return
	}
	req.Header.Set("Content-Type", "application/json")
	
	resp, err := c.Client.Do(req)
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		return
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	fmt.Printf("✅ Status: %s (%d)\n", resp.Status, resp.StatusCode)
	fmt.Printf("Response:\n%s\n", string(body))
}

func (c *CLIClient) putRequest(path, payload, title string) {
	fmt.Printf("\n⏳ %s...\n", title)
	
	req, err := http.NewRequest("PUT", c.BaseURL+path, strings.NewReader(payload))
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		return
	}
	req.Header.Set("Content-Type", "application/json")
	
	resp, err := c.Client.Do(req)
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		return
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	fmt.Printf("✅ Status: %s (%d)\n", resp.Status, resp.StatusCode)
	fmt.Printf("Response:\n%s\n", string(body))
}

func (c *CLIClient) deleteRequest(path, title string) {
	fmt.Printf("\n⏳ %s...\n", title)
	
	req, err := http.NewRequest("DELETE", c.BaseURL+path, nil)
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		return
	}
	
	resp, err := c.Client.Do(req)
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		return
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	fmt.Printf("✅ Status: %s (%d)\n", resp.Status, resp.StatusCode)
	fmt.Printf("Response:\n%s\n", string(body))
}

func (c *CLIClient) viewMetrics() {
	fmt.Println("\n⏳ Fetching Prometheus metrics...\n")
	
	resp, err := c.Client.Get(c.BaseURL + "/metrics")
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		return
	}

	// Show first 1000 characters of metrics
	lines := strings.Split(string(body), "\n")
	count := 0
	for _, line := range lines {
		if strings.HasPrefix(line, "http_") {
			fmt.Println(line)
			count++
			if count >= 20 {
				fmt.Println("\n... (truncated, showing first 20 HTTP metrics)")
				break
			}
		}
	}
}

func (c *CLIClient) viewHTTPMetrics() {
	c.viewMetrics()
}

func (c *CLIClient) viewActiveRequests() {
	fmt.Println("\n⏳ Fetching active requests metric...\n")
	
	resp, err := c.Client.Get(c.BaseURL + "/metrics")
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		return
	}

	lines := strings.Split(string(body), "\n")
	for _, line := range lines {
		if strings.Contains(line, "http_requests_active") {
			fmt.Println(line)
		}
	}
}

func main() {
	serverURL := os.Getenv("SERVER_URL")
	if serverURL == "" {
		serverURL = "http://localhost:8080"
	}

	fmt.Println("╔═══════════════════════════════════════════╗")
	fmt.Println("║                                           ║")
	fmt.Println("║   Echo Server CLI Tool                   ║")
	fmt.Println("║   Server:", serverURL)
	fmt.Println("║                                           ║")
	fmt.Println("╚═══════════════════════════════════════════╝")

	client := NewCLIClient(serverURL)
	client.ShowMenu()
}
