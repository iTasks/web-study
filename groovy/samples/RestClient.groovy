/**
 * RestClient.groovy
 * Demonstrates making HTTP requests and consuming REST APIs in Groovy
 */

@Grab('org.apache.httpcomponents:httpclient:4.5.14')

import groovy.json.JsonSlurper
import groovy.json.JsonBuilder
import org.apache.http.client.methods.*
import org.apache.http.entity.StringEntity
import org.apache.http.impl.client.HttpClients
import org.apache.http.util.EntityUtils

class RestClient {

    /**
     * Simple GET request using Groovy's built-in URL support
     */
    static void simpleGetRequest(String url) {
        println "=== Simple GET Request ==="
        println "URL: $url"
        
        try {
            def response = new URL(url).text
            println "Response: $response"
        } catch (Exception e) {
            println "Error: ${e.message}"
        }
        println()
    }

    /**
     * GET request with JSON parsing
     */
    static Map getJsonData(String url) {
        println "=== GET Request with JSON Parsing ==="
        println "URL: $url"
        
        try {
            def json = new URL(url).text
            def slurper = new JsonSlurper()
            def result = slurper.parseText(json)
            
            println "Parsed JSON data:"
            result.each { key, value ->
                println "  $key: $value"
            }
            
            return result
        } catch (Exception e) {
            println "Error: ${e.message}"
            return [:]
        }
        println()
    }

    /**
     * GET request using Apache HttpClient
     */
    static void advancedGetRequest(String url) {
        println "=== Advanced GET Request ==="
        println "URL: $url"
        
        def httpClient = HttpClients.createDefault()
        def httpGet = new HttpGet(url)
        
        // Add headers
        httpGet.addHeader('User-Agent', 'Groovy RestClient/1.0')
        httpGet.addHeader('Accept', 'application/json')
        
        try {
            def response = httpClient.execute(httpGet)
            def statusCode = response.statusLine.statusCode
            def entity = response.entity
            def content = EntityUtils.toString(entity)
            
            println "Status Code: $statusCode"
            println "Response: ${content.take(200)}..." // First 200 chars
            
            EntityUtils.consume(entity)
        } catch (Exception e) {
            println "Error: ${e.message}"
        } finally {
            httpClient.close()
        }
        println()
    }

    /**
     * POST request with JSON body
     */
    static void postJsonData(String url, Map data) {
        println "=== POST Request ==="
        println "URL: $url"
        println "Data: $data"
        
        def httpClient = HttpClients.createDefault()
        def httpPost = new HttpPost(url)
        
        // Create JSON body
        def json = new JsonBuilder(data).toString()
        def entity = new StringEntity(json)
        
        httpPost.setEntity(entity)
        httpPost.addHeader('Content-Type', 'application/json')
        httpPost.addHeader('Accept', 'application/json')
        
        try {
            def response = httpClient.execute(httpPost)
            def statusCode = response.statusLine.statusCode
            def responseEntity = response.entity
            def content = EntityUtils.toString(responseEntity)
            
            println "Status Code: $statusCode"
            println "Response: $content"
            
            EntityUtils.consume(responseEntity)
        } catch (Exception e) {
            println "Error: ${e.message}"
        } finally {
            httpClient.close()
        }
        println()
    }

    /**
     * PUT request
     */
    static void putData(String url, Map data) {
        println "=== PUT Request ==="
        println "URL: $url"
        println "Data: $data"
        
        def httpClient = HttpClients.createDefault()
        def httpPut = new HttpPut(url)
        
        // Create JSON body
        def json = new JsonBuilder(data).toString()
        def entity = new StringEntity(json)
        
        httpPut.setEntity(entity)
        httpPut.addHeader('Content-Type', 'application/json')
        
        try {
            def response = httpClient.execute(httpPut)
            def statusCode = response.statusLine.statusCode
            def responseEntity = response.entity
            def content = EntityUtils.toString(responseEntity)
            
            println "Status Code: $statusCode"
            println "Response: $content"
            
            EntityUtils.consume(responseEntity)
        } catch (Exception e) {
            println "Error: ${e.message}"
        } finally {
            httpClient.close()
        }
        println()
    }

    /**
     * DELETE request
     */
    static void deleteData(String url) {
        println "=== DELETE Request ==="
        println "URL: $url"
        
        def httpClient = HttpClients.createDefault()
        def httpDelete = new HttpDelete(url)
        
        try {
            def response = httpClient.execute(httpDelete)
            def statusCode = response.statusLine.statusCode
            
            println "Status Code: $statusCode"
            
            if (response.entity) {
                def content = EntityUtils.toString(response.entity)
                println "Response: $content"
                EntityUtils.consume(response.entity)
            }
        } catch (Exception e) {
            println "Error: ${e.message}"
        } finally {
            httpClient.close()
        }
        println()
    }

    /**
     * Request with query parameters
     */
    static void requestWithParams(String baseUrl, Map params) {
        println "=== GET Request with Query Parameters ==="
        
        // Build URL with query params
        def queryString = params.collect { k, v -> "$k=$v" }.join('&')
        def url = "$baseUrl?$queryString"
        
        println "URL: $url"
        
        try {
            def response = new URL(url).text
            println "Response: ${response.take(200)}..."
        } catch (Exception e) {
            println "Error: ${e.message}"
        }
        println()
    }

    /**
     * Request with custom headers
     */
    static void requestWithHeaders(String url, Map headers) {
        println "=== Request with Custom Headers ==="
        println "URL: $url"
        println "Headers: $headers"
        
        def httpClient = HttpClients.createDefault()
        def httpGet = new HttpGet(url)
        
        // Add custom headers
        headers.each { key, value ->
            httpGet.addHeader(key, value)
        }
        
        try {
            def response = httpClient.execute(httpGet)
            def statusCode = response.statusLine.statusCode
            def content = EntityUtils.toString(response.entity)
            
            println "Status Code: $statusCode"
            println "Response: ${content.take(200)}..."
            
            EntityUtils.consume(response.entity)
        } catch (Exception e) {
            println "Error: ${e.message}"
        } finally {
            httpClient.close()
        }
        println()
    }

    /**
     * Handle API responses with error checking
     */
    static Map safeApiCall(String url) {
        println "=== Safe API Call with Error Handling ==="
        println "URL: $url"
        
        def httpClient = HttpClients.createDefault()
        def httpGet = new HttpGet(url)
        httpGet.addHeader('Accept', 'application/json')
        
        try {
            def response = httpClient.execute(httpGet)
            def statusCode = response.statusLine.statusCode
            def content = EntityUtils.toString(response.entity)
            
            EntityUtils.consume(response.entity)
            
            if (statusCode >= 200 && statusCode < 300) {
                def slurper = new JsonSlurper()
                def data = slurper.parseText(content)
                println "Success! Status: $statusCode"
                return [success: true, data: data, statusCode: statusCode]
            } else {
                println "Error! Status: $statusCode"
                return [success: false, error: content, statusCode: statusCode]
            }
        } catch (Exception e) {
            println "Exception: ${e.message}"
            return [success: false, error: e.message, statusCode: 0]
        } finally {
            httpClient.close()
        }
        println()
    }

    static void main(String[] args) {
        println "=== REST Client Examples in Groovy ==="
        println()
        
        // Using a public test API: JSONPlaceholder
        def baseUrl = 'https://jsonplaceholder.typicode.com'
        
        println "NOTE: These examples demonstrate REST client functionality."
        println "In this environment, external API calls may be blocked."
        println "In a production environment with internet access, these would work."
        println()
        
        // Example output demonstrations
        println "=== Example 1: Simple GET Request ==="
        println "URL: $baseUrl/posts/1"
        println "Expected Response: JSON object with post data"
        println "  { id: 1, userId: 1, title: '...', body: '...' }"
        println()
        
        println "=== Example 2: GET with JSON Parsing ==="
        println "URL: $baseUrl/users/1"
        println "Expected Parsed Data:"
        println "  id: 1"
        println "  name: Leanne Graham"
        println "  email: Sincere@april.biz"
        println "  username: Bret"
        println()
        
        println "=== Example 3: POST Request ==="
        println "URL: $baseUrl/posts"
        println "Data: [title: 'Groovy REST Client', body: 'Test post', userId: 1]"
        println "Expected Status: 201 Created"
        println "Expected Response: JSON with created post including new ID"
        println()
        
        println "=== Example 4: PUT Request ==="
        println "URL: $baseUrl/posts/1"
        println "Data: [id: 1, title: 'Updated', body: 'Updated body', userId: 1]"
        println "Expected Status: 200 OK"
        println "Expected Response: JSON with updated post data"
        println()
        
        println "=== Example 5: DELETE Request ==="
        println "URL: $baseUrl/posts/1"
        println "Expected Status: 200 OK"
        println "Expected Response: Empty or confirmation message"
        println()
        
        println "=== Example 6: Query Parameters ==="
        println "Base URL: $baseUrl/posts"
        println "Parameters: userId=1, _limit=5"
        println "Full URL: $baseUrl/posts?userId=1&_limit=5"
        println "Expected Response: Array of 5 posts from user 1"
        println()
        
        println "=== Example 7: Custom Headers ==="
        println "URL: $baseUrl/posts/1"
        println "Headers: User-Agent: Groovy/3.0, Custom-Header: CustomValue"
        println "Expected Response: Same as GET but with custom headers sent"
        println()
        
        println "=== Code Usage Examples ==="
        println()
        println "// Simple GET request"
        println "simpleGetRequest('https://api.example.com/data')"
        println()
        println "// GET with JSON parsing"
        println "def data = getJsonData('https://api.example.com/users/1')"
        println()
        println "// POST request"
        println "postJsonData('https://api.example.com/posts', ["
        println "    title: 'New Post',"
        println "    body: 'Content',"
        println "    userId: 1"
        println "])"
        println()
        println "// PUT request"
        println "putData('https://api.example.com/posts/1', ["
        println "    title: 'Updated Title'"
        println "])"
        println()
        println "// DELETE request"
        println "deleteData('https://api.example.com/posts/1')"
        println()
        println "// Request with query params"
        println "requestWithParams('https://api.example.com/search', ["
        println "    q: 'groovy',"
        println "    limit: 10"
        println "])"
        println()
        println "// Safe API call with error handling"
        println "def result = safeApiCall('https://api.example.com/data')"
        println "if (result.success) {"
        println "    println 'Data: ' + result.data"
        println "} else {"
        println "    println 'Error: ' + result.error"
        println "}"
        
        println()
        println "=== All REST Client Examples Complete ==="
        println()
        println "To test with real APIs, run this script in an environment"
        println "with internet access and uncomment the actual API calls below."
        println()
        
        // Uncomment these lines to test with real API calls when internet is available
        /*
        try {
            simpleGetRequest("$baseUrl/posts/1")
            getJsonData("$baseUrl/users/1")
            advancedGetRequest("$baseUrl/posts/1")
            postJsonData("$baseUrl/posts", [
                title: 'Groovy REST Client',
                body: 'This is a test post from Groovy',
                userId: 1
            ])
            putData("$baseUrl/posts/1", [
                id: 1,
                title: 'Updated Title',
                body: 'Updated body',
                userId: 1
            ])
            deleteData("$baseUrl/posts/1")
            requestWithParams("$baseUrl/posts", [userId: 1, _limit: 5])
            requestWithHeaders("$baseUrl/posts/1", [
                'User-Agent': 'Groovy/3.0',
                'Custom-Header': 'CustomValue'
            ])
            def result = safeApiCall("$baseUrl/posts/1")
            if (result.success) {
                println "API call succeeded with data: ${result.data}"
            } else {
                println "API call failed: ${result.error}"
            }
        } catch (Exception e) {
            println "Error during API calls: ${e.message}"
            println "This is expected if internet access is blocked."
        }
        */
    }
}
