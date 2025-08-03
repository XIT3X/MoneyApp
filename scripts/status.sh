#!/bin/bash

# MoneyApp Status Monitoring Script
# This script checks the status of backup and CI/CD systems

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== MoneyApp Status Report ===${NC}"
echo ""

# Check if automatic backup service is running
echo -e "${YELLOW}1. Automatic Backup Service:${NC}"
if launchctl list | grep -q "com.marco.moneyapp.backup"; then
    echo -e "${GREEN}✓ Service is loaded and running${NC}"
else
    echo -e "${RED}✗ Service is not running${NC}"
fi
echo ""

# Check recent backup files
echo -e "${YELLOW}2. Recent Backups:${NC}"
BACKUP_DIR="$HOME/Documents/MoneyApp_Backups"
if [ -d "$BACKUP_DIR" ]; then
    echo "Backup directory: $BACKUP_DIR"
    echo "Recent backups:"
    ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -5 || echo "No backup files found"
else
    echo -e "${RED}Backup directory not found${NC}"
fi
echo ""

# Check git status
echo -e "${YELLOW}3. Git Status:${NC}"
cd /Users/marco/Desktop/MoneyApp
if git diff-index --quiet HEAD --; then
    echo -e "${GREEN}✓ Working directory is clean${NC}"
else
    echo -e "${YELLOW}! Working directory has uncommitted changes${NC}"
    git status --porcelain
fi
echo ""

# Check GitHub remote
echo -e "${YELLOW}4. GitHub Connection:${NC}"
if git remote -v | grep -q "github.com"; then
    echo -e "${GREEN}✓ GitHub remote configured${NC}"
    echo "Repository: $(git remote get-url origin)"
else
    echo -e "${RED}✗ GitHub remote not configured${NC}"
fi
echo ""

# Check recent logs
echo -e "${YELLOW}5. Recent Backup Logs:${NC}"
LOG_FILE="$HOME/Library/Logs/MoneyApp/backup.log"
if [ -f "$LOG_FILE" ]; then
    echo "Last 5 log entries:"
    tail -5 "$LOG_FILE" 2>/dev/null || echo "No log entries found"
else
    echo -e "${RED}Log file not found${NC}"
fi
echo ""

# Check GitHub Actions status
echo -e "${YELLOW}6. GitHub Actions Status:${NC}"
if [ -f ".github/workflows/ios-build.yml" ]; then
    echo -e "${GREEN}✓ GitHub Actions workflow configured${NC}"
    echo "Workflow: .github/workflows/ios-build.yml"
    echo "Triggers: Push to main/develop, Pull requests"
else
    echo -e "${RED}✗ GitHub Actions workflow not found${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
echo "• Automatic backup runs daily at 9:00 AM"
echo "• Local backups stored in: $BACKUP_DIR"
echo "• GitHub repository: https://github.com/XIT3X/MoneyApp.git"
echo "• Logs location: $HOME/Library/Logs/MoneyApp/"
echo ""
echo -e "${GREEN}Status check completed!${NC}" 