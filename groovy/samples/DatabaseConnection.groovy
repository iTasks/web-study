/**
 * DatabaseConnection.groovy
 * Demonstrates database connectivity and SQL operations in Groovy
 */

@Grab('com.h2database:h2:2.2.224')
@GrabConfig(systemClassLoader=true)

import groovy.sql.Sql
import java.sql.SQLException

class DatabaseConnection {

    /**
     * Create an in-memory H2 database connection
     */
    static Sql createConnection() {
        def url = 'jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1'
        def user = 'sa'
        def password = ''
        def driver = 'org.h2.Driver'
        
        return Sql.newInstance(url, user, password, driver)
    }

    /**
     * Create tables
     */
    static void createTables(Sql sql) {
        println "=== Creating Tables ==="
        
        // Drop tables if they exist
        sql.execute('''
            DROP TABLE IF EXISTS orders
        ''')
        
        sql.execute('''
            DROP TABLE IF EXISTS users
        ''')
        
        // Create users table
        sql.execute('''
            CREATE TABLE users (
                id INT PRIMARY KEY AUTO_INCREMENT,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                age INT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        // Create orders table
        sql.execute('''
            CREATE TABLE orders (
                id INT PRIMARY KEY AUTO_INCREMENT,
                user_id INT,
                product VARCHAR(100),
                quantity INT,
                price DECIMAL(10, 2),
                order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        ''')
        
        println "Tables created successfully"
        println()
    }

    /**
     * Insert data
     */
    static void insertData(Sql sql) {
        println "=== Inserting Data ==="
        
        // Insert users
        sql.execute('''
            INSERT INTO users (name, email, age) 
            VALUES (?, ?, ?)
        ''', ['Alice Johnson', 'alice@example.com', 28])
        
        sql.execute('''
            INSERT INTO users (name, email, age) 
            VALUES (?, ?, ?)
        ''', ['Bob Smith', 'bob@example.com', 34])
        
        sql.execute('''
            INSERT INTO users (name, email, age) 
            VALUES (?, ?, ?)
        ''', ['Charlie Brown', 'charlie@example.com', 22])
        
        println "Users inserted"
        
        // Insert orders
        sql.execute('''
            INSERT INTO orders (user_id, product, quantity, price) 
            VALUES (?, ?, ?, ?)
        ''', [1, 'Laptop', 1, 999.99])
        
        sql.execute('''
            INSERT INTO orders (user_id, product, quantity, price) 
            VALUES (?, ?, ?, ?)
        ''', [1, 'Mouse', 2, 29.99])
        
        sql.execute('''
            INSERT INTO orders (user_id, product, quantity, price) 
            VALUES (?, ?, ?, ?)
        ''', [2, 'Keyboard', 1, 79.99])
        
        println "Orders inserted"
        println()
    }

    /**
     * Query all users
     */
    static void queryAllUsers(Sql sql) {
        println "=== Querying All Users ==="
        
        sql.eachRow('SELECT * FROM users') { row ->
            println "ID: ${row.id}, Name: ${row.name}, Email: ${row.email}, Age: ${row.age}"
        }
        println()
    }

    /**
     * Query with parameters
     */
    static void queryWithParameters(Sql sql, int minAge) {
        println "=== Querying Users with Age >= $minAge ==="
        
        def rows = sql.rows('SELECT * FROM users WHERE age >= ?', [minAge])
        rows.each { row ->
            println "  ${row.name} (${row.age} years old)"
        }
        println()
    }

    /**
     * Query single row
     */
    static void querySingleUser(Sql sql, String email) {
        println "=== Querying Single User by Email ==="
        println "Email: $email"
        
        def row = sql.firstRow('SELECT * FROM users WHERE email = ?', [email])
        if (row) {
            println "Found: ${row.name}, Age: ${row.age}"
        } else {
            println "User not found"
        }
        println()
    }

    /**
     * Update data
     */
    static void updateData(Sql sql, String email, int newAge) {
        println "=== Updating User Age ==="
        println "Email: $email, New Age: $newAge"
        
        def count = sql.executeUpdate('''
            UPDATE users SET age = ? WHERE email = ?
        ''', [newAge, email])
        
        println "Updated $count row(s)"
        println()
    }

    /**
     * Delete data
     */
    static void deleteData(Sql sql, String email) {
        println "=== Deleting User ==="
        println "Email: $email"
        
        def count = sql.executeUpdate('''
            DELETE FROM users WHERE email = ?
        ''', [email])
        
        println "Deleted $count row(s)"
        println()
    }

    /**
     * Transaction example
     */
    static void transactionExample(Sql sql) {
        println "=== Transaction Example ==="
        
        try {
            sql.withTransaction {
                // Insert a new user
                sql.execute('''
                    INSERT INTO users (name, email, age) 
                    VALUES (?, ?, ?)
                ''', ['David Wilson', 'david@example.com', 30])
                
                // Get the generated ID
                def row = sql.firstRow('SELECT id FROM users WHERE email = ?', ['david@example.com'])
                def userId = row.id
                
                // Insert an order for the new user
                sql.execute('''
                    INSERT INTO orders (user_id, product, quantity, price) 
                    VALUES (?, ?, ?, ?)
                ''', [userId, 'Monitor', 2, 299.99])
                
                println "Transaction committed successfully"
            }
        } catch (SQLException e) {
            println "Transaction failed: ${e.message}"
        }
        println()
    }

    /**
     * Join query example
     */
    static void joinQueryExample(Sql sql) {
        println "=== Join Query Example ==="
        println "Users and their orders:"
        
        def query = '''
            SELECT u.name, u.email, o.product, o.quantity, o.price 
            FROM users u
            LEFT JOIN orders o ON u.id = o.user_id
            ORDER BY u.name, o.product
        '''
        
        sql.eachRow(query) { row ->
            if (row.product) {
                println "  ${row.name}: ${row.quantity}x ${row.product} @ \$${row.price}"
            } else {
                println "  ${row.name}: No orders"
            }
        }
        println()
    }

    /**
     * Aggregate functions
     */
    static void aggregateExample(Sql sql) {
        println "=== Aggregate Functions ==="
        
        // Count users
        def countRow = sql.firstRow('SELECT COUNT(*) as count FROM users')
        println "Total users: ${countRow.count}"
        
        // Average age
        def avgRow = sql.firstRow('SELECT AVG(age) as avg_age FROM users')
        println "Average age: ${avgRow.avg_age}"
        
        // Total order value by user
        println "\nTotal order value by user:"
        sql.eachRow('''
            SELECT u.name, SUM(o.quantity * o.price) as total
            FROM users u
            LEFT JOIN orders o ON u.id = o.user_id
            GROUP BY u.id, u.name
            ORDER BY total DESC
        ''') { row ->
            def total = row.total ?: 0
            def formattedTotal = total instanceof Number ? String.format('%.2f', total as Double) : '0.00'
            println "  ${row.name}: \$$formattedTotal"
        }
        println()
    }

    /**
     * Batch insert
     */
    static void batchInsertExample(Sql sql) {
        println "=== Batch Insert Example ==="
        
        def users = [
            ['Emma Davis', 'emma@example.com', 26],
            ['Frank Miller', 'frank@example.com', 31],
            ['Grace Lee', 'grace@example.com', 27]
        ]
        
        sql.withBatch(3, '''
            INSERT INTO users (name, email, age) VALUES (?, ?, ?)
        ''') { ps ->
            users.each { user ->
                ps.addBatch(user)
            }
        }
        
        println "Batch insert completed for ${users.size()} users"
        println()
    }

    /**
     * Metadata example
     */
    static void metadataExample(Sql sql) {
        println "=== Database Metadata ==="
        
        // Get table columns
        def meta = sql.connection.metaData
        def rs = meta.getColumns(null, null, 'USERS', null)
        
        println "Columns in USERS table:"
        while (rs.next()) {
            def columnName = rs.getString('COLUMN_NAME')
            def dataType = rs.getString('TYPE_NAME')
            println "  $columnName ($dataType)"
        }
        rs.close()
        println()
    }

    static void main(String[] args) {
        println "=== Database Connection Examples in Groovy ==="
        println()
        
        def sql = null
        
        try {
            // Create connection
            sql = createConnection()
            println "Connected to database successfully"
            println()
            
            // Create tables
            createTables(sql)
            
            // Insert data
            insertData(sql)
            
            // Query all users
            queryAllUsers(sql)
            
            // Query with parameters
            queryWithParameters(sql, 25)
            
            // Query single user
            querySingleUser(sql, 'alice@example.com')
            
            // Update data
            updateData(sql, 'bob@example.com', 35)
            queryAllUsers(sql)
            
            // Join query
            joinQueryExample(sql)
            
            // Aggregate functions
            aggregateExample(sql)
            
            // Transaction example
            transactionExample(sql)
            
            // Batch insert
            batchInsertExample(sql)
            queryAllUsers(sql)
            
            // Metadata
            metadataExample(sql)
            
            // Delete data
            deleteData(sql, 'charlie@example.com')
            queryAllUsers(sql)
            
        } catch (Exception e) {
            println "Error: ${e.message}"
            e.printStackTrace()
        } finally {
            // Close connection
            if (sql) {
                sql.close()
                println "Database connection closed"
            }
        }
        
        println()
        println "=== All Database Examples Complete ==="
    }
}
