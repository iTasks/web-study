/**
 * FileOperations.groovy
 * Demonstrates file I/O operations in Groovy
 */

class FileOperations {

    /**
     * Write text to a file
     */
    static void writeTextFile(String filename, String content) {
        new File(filename).text = content
        println "Written to $filename"
    }

    /**
     * Read text from a file
     */
    static String readTextFile(String filename) {
        return new File(filename).text
    }

    /**
     * Append text to a file
     */
    static void appendToFile(String filename, String content) {
        new File(filename).append(content)
        println "Appended to $filename"
    }

    /**
     * Read file line by line
     */
    static void readFileLineByLine(String filename) {
        println "Reading $filename line by line:"
        new File(filename).eachLine { line, lineNumber ->
            println "  Line $lineNumber: $line"
        }
    }

    /**
     * Write lines to a file
     */
    static void writeLines(String filename, List<String> lines) {
        new File(filename).withWriter { writer ->
            lines.each { line ->
                writer.writeLine(line)
            }
        }
        println "Written lines to $filename"
    }

    /**
     * Copy a file
     */
    static void copyFile(String source, String destination) {
        new File(destination).withOutputStream { out ->
            new File(source).withInputStream { input ->
                out << input
            }
        }
        println "Copied $source to $destination"
    }

    /**
     * Delete a file
     */
    static boolean deleteFile(String filename) {
        def file = new File(filename)
        if (file.exists()) {
            def deleted = file.delete()
            println "Deleted $filename: $deleted"
            return deleted
        }
        println "File $filename does not exist"
        return false
    }

    /**
     * List files in a directory
     */
    static void listFilesInDirectory(String directory) {
        println "Files in $directory:"
        new File(directory).eachFile { file ->
            println "  ${file.name} (${file.isDirectory() ? 'DIR' : 'FILE'})"
        }
    }

    /**
     * Create a directory
     */
    static boolean createDirectory(String path) {
        def dir = new File(path)
        if (!dir.exists()) {
            def created = dir.mkdirs()
            println "Created directory $path: $created"
            return created
        }
        println "Directory $path already exists"
        return false
    }

    /**
     * Get file size
     */
    static long getFileSize(String filename) {
        def file = new File(filename)
        if (file.exists()) {
            return file.length()
        }
        return 0
    }

    /**
     * Check if file exists
     */
    static boolean fileExists(String filename) {
        return new File(filename).exists()
    }

    /**
     * Read file with filtering
     */
    static List<String> readLinesMatching(String filename, String pattern) {
        def lines = []
        new File(filename).eachLine { line ->
            if (line.contains(pattern)) {
                lines << line
            }
        }
        return lines
    }

    /**
     * Count lines in a file
     */
    static int countLines(String filename) {
        int count = 0
        new File(filename).eachLine { count++ }
        return count
    }

    /**
     * Find files recursively
     */
    static void findFilesRecursively(String directory, String extension) {
        println "Finding all .$extension files in $directory:"
        new File(directory).eachFileRecurse { file ->
            if (file.name.endsWith(".$extension")) {
                println "  ${file.absolutePath}"
            }
        }
    }

    static void main(String[] args) {
        println "=== File Operations in Groovy ==="
        println()

        // Create a temporary directory for our tests
        def tempDir = "/tmp/groovy-file-ops-${System.currentTimeMillis()}"
        createDirectory(tempDir)
        println()

        // Write a file
        def testFile = "$tempDir/test.txt"
        writeTextFile(testFile, "Hello, Groovy!\nThis is a test file.\n")
        println()

        // Read the file
        println "File content:"
        println readTextFile(testFile)
        println()

        // Append to the file
        appendToFile(testFile, "This line was appended.\n")
        println()

        // Read line by line
        readFileLineByLine(testFile)
        println()

        // Write lines
        def linesFile = "$tempDir/lines.txt"
        writeLines(linesFile, ['Line 1', 'Line 2', 'Line 3', 'Line 4', 'Line 5'])
        println()

        // Count lines
        println "Number of lines in $linesFile: ${countLines(linesFile)}"
        println()

        // Get file size
        println "Size of $testFile: ${getFileSize(testFile)} bytes"
        println()

        // Check if file exists
        println "File $testFile exists: ${fileExists(testFile)}"
        println()

        // Copy a file
        def copiedFile = "$tempDir/test_copy.txt"
        copyFile(testFile, copiedFile)
        println()

        // List files in directory
        listFilesInDirectory(tempDir)
        println()

        // Read lines matching pattern
        println "Lines containing 'test' in $testFile:"
        readLinesMatching(testFile, 'test').each { line ->
            println "  $line"
        }
        println()

        // Create subdirectory
        def subDir = "$tempDir/subdir"
        createDirectory(subDir)
        writeTextFile("$subDir/nested.groovy", "// Groovy file")
        println()

        // Find files recursively
        findFilesRecursively(tempDir, "txt")
        println()

        // Cleanup - delete files and directory
        println "Cleaning up..."
        deleteFile(testFile)
        deleteFile(linesFile)
        deleteFile(copiedFile)
        deleteFile("$subDir/nested.groovy")
        new File(subDir).delete()
        new File(tempDir).delete()
        println "Cleanup complete"
    }
}
