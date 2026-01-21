#!/bin/bash
# Example 1: Basic File Operations
# This script demonstrates common Linux file operations

echo "=== File Operations Demo ==="

# Create a test directory
TEST_DIR="$HOME/linux-practice"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR" || exit

echo "Created test directory: $TEST_DIR"

# Create some files
echo "Creating test files..."
echo "This is file 1" > file1.txt
echo "This is file 2" > file2.txt
echo "This is file 3" > file3.txt

# List files
echo -e "\nListing files:"
ls -la

# Copy files
echo -e "\nCopying files..."
cp file1.txt file1-backup.txt
cp -v file2.txt file2-backup.txt

# Move/rename files
echo -e "\nRenaming file3.txt to file3-renamed.txt"
mv file3.txt file3-renamed.txt

# Create subdirectories
echo -e "\nCreating subdirectories..."
mkdir -p backups logs configs

# Move backup files to backups directory
mv *-backup.txt backups/

# Show final structure
echo -e "\nFinal directory structure:"
ls -lR

# Count files
echo -e "\nTotal files: $(find . -type f | wc -l)"
echo "Total directories: $(find . -type d | wc -l)"

echo -e "\nDemo complete! Check $TEST_DIR to see the results."
