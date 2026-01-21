#!/bin/bash
# Example 4: Automated Backup Script
# Creates compressed backups with timestamps and manages old backups

# Configuration
SOURCE_DIR="${1:-$HOME/documents}"
BACKUP_DIR="${2:-$HOME/backups}"
RETENTION_DAYS=7
MAX_BACKUPS=5
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${DATE}.tar.gz"
LOG_FILE="$BACKUP_DIR/backup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    log "ERROR: $1"
    exit 1
}

# Check if source exists
if [ ! -d "$SOURCE_DIR" ]; then
    error_exit "Source directory $SOURCE_DIR does not exist"
fi

# Create backup directory
mkdir -p "$BACKUP_DIR" || error_exit "Failed to create backup directory"

# Start backup
echo -e "${YELLOW}Starting backup process...${NC}"
log "Starting backup of $SOURCE_DIR"

# Calculate source size
SOURCE_SIZE=$(du -sh "$SOURCE_DIR" 2>/dev/null | cut -f1)
log "Source directory size: $SOURCE_SIZE"

# Create backup
echo "Creating backup: $BACKUP_NAME"
tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" 2>/dev/null

# Check if backup was successful
if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR/$BACKUP_NAME" | cut -f1)
    echo -e "${GREEN}✓ Backup created successfully${NC}"
    log "Backup successful: $BACKUP_NAME (Size: $BACKUP_SIZE)"
else
    error_exit "Backup failed"
fi

# Cleanup old backups based on retention policy
echo "Cleaning up old backups..."
log "Cleaning up backups older than $RETENTION_DAYS days"

# Remove backups older than RETENTION_DAYS
find "$BACKUP_DIR" -name "backup_*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null
REMOVED_COUNT=$?

# Keep only last MAX_BACKUPS
cd "$BACKUP_DIR" || exit
BACKUP_COUNT=$(ls -1 backup_*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
    EXCESS=$((BACKUP_COUNT - MAX_BACKUPS))
    ls -t backup_*.tar.gz | tail -n $EXCESS | xargs rm -f
    log "Removed $EXCESS old backup(s) to maintain max $MAX_BACKUPS backups"
fi

# Display backup summary
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║           BACKUP SUMMARY                       ║"
echo "╚════════════════════════════════════════════════╝"
echo "Source: $SOURCE_DIR ($SOURCE_SIZE)"
echo "Destination: $BACKUP_DIR/$BACKUP_NAME"
echo "Backup Size: $BACKUP_SIZE"
echo "Current Backups: $(ls -1 "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | wc -l)"
echo ""
echo "Recent backups:"
ls -lth "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | head -5

echo -e "\n${GREEN}Backup completed successfully!${NC}"
log "Backup process completed"
