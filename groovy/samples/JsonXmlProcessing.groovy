/**
 * JsonXmlProcessing.groovy
 * Demonstrates JSON and XML processing in Groovy
 */

import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import groovy.xml.MarkupBuilder
import groovy.xml.XmlSlurper

class JsonXmlProcessing {

    /**
     * Create JSON from Groovy objects
     */
    static String createJson() {
        def builder = new JsonBuilder()
        
        builder.person {
            name 'John Doe'
            age 30
            email 'john.doe@example.com'
            address {
                street '123 Main St'
                city 'New York'
                zipCode '10001'
            }
            hobbies(['reading', 'coding', 'traveling'])
        }
        
        return builder.toPrettyString()
    }

    /**
     * Create JSON array
     */
    static String createJsonArray() {
        def builder = new JsonBuilder()
        
        def people = [
            [name: 'Alice', age: 25, city: 'Boston'],
            [name: 'Bob', age: 30, city: 'Chicago'],
            [name: 'Charlie', age: 35, city: 'Denver']
        ]
        
        builder(people)
        
        return builder.toPrettyString()
    }

    /**
     * Parse JSON string
     */
    static void parseJson(String jsonString) {
        def slurper = new JsonSlurper()
        def result = slurper.parseText(jsonString)
        
        println "Parsed JSON:"
        if (result instanceof Map) {
            result.each { key, value ->
                println "  $key: $value"
            }
        } else if (result instanceof List) {
            result.eachWithIndex { item, idx ->
                println "  Item $idx: $item"
            }
        }
    }

    /**
     * Modify JSON
     */
    static String modifyJson(String jsonString) {
        def slurper = new JsonSlurper()
        def person = slurper.parseText(jsonString)
        
        // Modify the data
        person.age = person.age + 1
        person.lastModified = new Date().format('yyyy-MM-dd')
        
        // Convert back to JSON
        def builder = new JsonBuilder(person)
        return builder.toPrettyString()
    }

    /**
     * Create XML from Groovy objects
     */
    static String createXml() {
        def writer = new StringWriter()
        def xml = new MarkupBuilder(writer)
        
        xml.person {
            name('John Doe')
            age(30)
            email('john.doe@example.com')
            address {
                street('123 Main St')
                city('New York')
                zipCode('10001')
            }
            hobbies {
                hobby('reading')
                hobby('coding')
                hobby('traveling')
            }
        }
        
        return writer.toString()
    }

    /**
     * Create complex XML structure
     */
    static String createComplexXml() {
        def writer = new StringWriter()
        def xml = new MarkupBuilder(writer)
        
        xml.library {
            books {
                book(isbn: '978-1234567890') {
                    title('Groovy in Action')
                    author('Dierk König')
                    price(49.99)
                    year(2015)
                }
                book(isbn: '978-0987654321') {
                    title('Programming Groovy')
                    author('Venkat Subramaniam')
                    price(45.00)
                    year(2016)
                }
            }
        }
        
        return writer.toString()
    }

    /**
     * Parse XML string
     */
    static void parseXml(String xmlString) {
        def xml = new XmlSlurper().parseText(xmlString)
        
        println "Parsed XML:"
        println "  Person name: ${xml.name}"
        println "  Person age: ${xml.age}"
        println "  Person email: ${xml.email}"
        println "  Address city: ${xml.address.city}"
        
        println "  Hobbies:"
        xml.hobbies.hobby.each { hobby ->
            println "    - $hobby"
        }
    }

    /**
     * Parse and query XML
     */
    static void queryXml(String xmlString) {
        def library = new XmlSlurper().parseText(xmlString)
        
        println "Books in library:"
        library.books.book.each { book ->
            println "  Title: ${book.title}"
            println "  Author: ${book.author}"
            println "  ISBN: ${book.@isbn}"
            println "  Price: \$${book.price}"
            println "  Year: ${book.year}"
            println()
        }
    }

    /**
     * Convert JSON to XML
     */
    static String jsonToXml(String jsonString) {
        def slurper = new JsonSlurper()
        def data = slurper.parseText(jsonString)
        
        def writer = new StringWriter()
        def xml = new MarkupBuilder(writer)
        
        xml.person {
            name(data.name)
            age(data.age)
            email(data.email)
            if (data.address) {
                address {
                    street(data.address.street)
                    city(data.address.city)
                    zipCode(data.address.zipCode)
                }
            }
        }
        
        return writer.toString()
    }

    /**
     * Filter and transform JSON data
     */
    static void transformJsonData() {
        def jsonData = '''
        [
            {"name": "Alice", "age": 25, "score": 85},
            {"name": "Bob", "age": 30, "score": 92},
            {"name": "Charlie", "age": 22, "score": 78},
            {"name": "David", "age": 28, "score": 95}
        ]
        '''
        
        def slurper = new JsonSlurper()
        def students = slurper.parseText(jsonData)
        
        // Filter students with score >= 80
        def topStudents = students.findAll { it.score >= 80 }
        
        // Transform data
        def result = topStudents.collect { student ->
            [
                name: student.name,
                age: student.age,
                score: student.score,
                grade: student.score >= 90 ? 'A' : 'B'
            ]
        }
        
        println "Top Students (score >= 80):"
        def builder = new JsonBuilder(result)
        println builder.toPrettyString()
    }

    static void main(String[] args) {
        println "=== JSON and XML Processing in Groovy ==="
        println()
        
        // JSON Creation
        println "=== Creating JSON ==="
        def json = createJson()
        println json
        println()
        
        // JSON Array
        println "=== Creating JSON Array ==="
        def jsonArray = createJsonArray()
        println jsonArray
        println()
        
        // Parse JSON
        println "=== Parsing JSON ==="
        parseJson(json)
        println()
        
        // Modify JSON
        println "=== Modifying JSON ==="
        def modifiedJson = modifyJson(json)
        println modifiedJson
        println()
        
        // XML Creation
        println "=== Creating XML ==="
        def xml = createXml()
        println xml
        println()
        
        // Complex XML
        println "=== Creating Complex XML ==="
        def complexXml = createComplexXml()
        println complexXml
        println()
        
        // Parse XML
        println "=== Parsing XML ==="
        parseXml(xml)
        println()
        
        // Query XML
        println "=== Querying XML ==="
        queryXml(complexXml)
        println()
        
        // JSON to XML conversion
        println "=== Converting JSON to XML ==="
        def convertedXml = jsonToXml(json)
        println convertedXml
        println()
        
        // Transform JSON data
        println "=== Transforming JSON Data ==="
        transformJsonData()
    }
}
