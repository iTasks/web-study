/**
 * RatpackApp.groovy
 * Simple Ratpack web application demonstrating REST API endpoints
 */

@Grab('io.ratpack:ratpack-groovy:1.9.0')
@Grab('org.slf4j:slf4j-simple:1.7.36')

import ratpack.groovy.Groovy
import ratpack.jackson.Jackson
import static ratpack.jackson.Jackson.json
import java.lang.management.ManagementFactory

// Sample data store
class UserStore {
    private static Map<Integer, Map> users = [
        1: [id: 1, name: 'Alice Johnson', email: 'alice@example.com', age: 28],
        2: [id: 2, name: 'Bob Smith', email: 'bob@example.com', age: 34],
        3: [id: 3, name: 'Charlie Brown', email: 'charlie@example.com', age: 22]
    ]
    
    static List<Map> getAll() {
        return users.values().toList()
    }
    
    static Map getById(int id) {
        return users[id]
    }
    
    static Map create(Map user) {
        def newId = users.keySet().max() + 1
        user.id = newId
        users[newId] = user
        return user
    }
    
    static Map update(int id, Map updates) {
        if (users.containsKey(id)) {
            users[id].putAll(updates)
            users[id].id = id  // Ensure ID doesn't change
            return users[id]
        }
        return null
    }
    
    static boolean delete(int id) {
        return users.remove(id) != null
    }
}

// Start the Ratpack server
Ratpack.start {
    handlers {
        
        // Root endpoint
        get {
            render """
                <html>
                <head><title>Groovy Ratpack API</title></head>
                <body>
                    <h1>Welcome to Groovy Ratpack REST API</h1>
                    <h2>Available Endpoints:</h2>
                    <ul>
                        <li>GET /api/users - Get all users</li>
                        <li>GET /api/users/:id - Get user by ID</li>
                        <li>POST /api/users - Create a new user</li>
                        <li>PUT /api/users/:id - Update user</li>
                        <li>DELETE /api/users/:id - Delete user</li>
                        <li>GET /api/health - Health check</li>
                    </ul>
                    <p>Example: <a href="/api/users">/api/users</a></p>
                </body>
                </html>
            """.stripIndent()
        }
        
        // Health check endpoint
        get('api/health') {
            render json([
                status: 'healthy',
                timestamp: new Date().toString(),
                uptime: ManagementFactory.getRuntimeMXBean().getUptime()
            ])
        }
        
        // Get all users
        get('api/users') {
            render json(UserStore.getAll())
        }
        
        // Get user by ID
        get('api/users/:id') {
            def id = context.pathTokens.id.toInteger()
            def user = UserStore.getById(id)
            
            if (user) {
                render json(user)
            } else {
                response.status(404)
                render json([error: "User not found", id: id])
            }
        }
        
        // Create new user
        post('api/users') {
            context.parse(Map).then { userData ->
                if (!userData.name || !userData.email) {
                    response.status(400)
                    render json([error: "Name and email are required"])
                } else {
                    def newUser = UserStore.create(userData)
                    response.status(201)
                    render json(newUser)
                }
            }
        }
        
        // Update user
        put('api/users/:id') {
            def id = context.pathTokens.id.toInteger()
            
            context.parse(Map).then { updates ->
                def updatedUser = UserStore.update(id, updates)
                
                if (updatedUser) {
                    render json(updatedUser)
                } else {
                    response.status(404)
                    render json([error: "User not found", id: id])
                }
            }
        }
        
        // Delete user
        delete('api/users/:id') {
            def id = context.pathTokens.id.toInteger()
            def deleted = UserStore.delete(id)
            
            if (deleted) {
                response.status(204)
                render ""
            } else {
                response.status(404)
                render json([error: "User not found", id: id])
            }
        }
        
        // 404 handler for all other requests
        all {
            response.status(404)
            render json([error: "Not found", path: request.path])
        }
    }
}
