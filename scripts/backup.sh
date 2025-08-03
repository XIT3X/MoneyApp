#!/bin/bash

# MoneyApp Automatic Backup Script
# This script performs automatic backup and sync to GitHub

set -e

# Configuration
PROJECT_DIR="/Users/marco/Desktop/MoneyApp"
BACKUP_DIR="$HOME/Documents/MoneyApp_Backups"
GITHUB_REPO="https://github.com/XIT3X/MoneyApp.git"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting MoneyApp backup process...${NC}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Navigate to project directory
cd "$PROJECT_DIR"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

# Create local backup
echo -e "${YELLOW}Creating local backup...${NC}"
tar -czf "$BACKUP_DIR/MoneyApp_backup_$TIMESTAMP.tar.gz" \
    --exclude='.git' \
    --exclude='*.xcuserdata' \
    --exclude='*.xcworkspace/xcuserdata' \
    --exclude='build' \
    --exclude='DerivedData' \
    .

echo -e "${GREEN}Local backup created: MoneyApp_backup_$TIMESTAMP.tar.gz${NC}"

# Check git status
echo -e "${YELLOW}Checking git status...${NC}"
git status --porcelain

# Add all changes
echo -e "${YELLOW}Adding changes to git...${NC}"
git add .

# Check if there are changes to commit
if git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}No changes to commit${NC}"
else
    # Commit changes
    echo -e "${YELLOW}Committing changes...${NC}"
    git commit -m "Auto backup - $TIMESTAMP"
    
    # Push to GitHub
    echo -e "${YELLOW}Pushing to GitHub...${NC}"
    git push origin main
    
    echo -e "${GREEN}Successfully pushed to GitHub!${NC}"
fi

# Clean up old backups (keep last 10)
echo -e "${YELLOW}Cleaning up old backups...${NC}"
cd "$BACKUP_DIR"
ls -t MoneyApp_backup_*.tar.gz | tail -n +11 | xargs -r rm

echo -e "${GREEN}Backup process completed successfully!${NC}"
echo -e "${GREEN}Backup location: $BACKUP_DIR${NC}"
echo -e "${GREEN}GitHub repository: $GITHUB_REPO${NC}" 