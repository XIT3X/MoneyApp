#!/bin/bash

# MoneyApp Automatic Backup Setup Script
# This script sets up automatic backup and GitHub sync

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== MoneyApp Automatic Backup Setup ===${NC}"

# Create log directory
echo -e "${YELLOW}Creating log directory...${NC}"
mkdir -p "$HOME/Library/Logs/MoneyApp"

# Copy plist file to LaunchAgents
echo -e "${YELLOW}Installing automatic backup service...${NC}"
cp scripts/com.marco.moneyapp.backup.plist "$HOME/Library/LaunchAgents/"

# Load the service
echo -e "${YELLOW}Loading automatic backup service...${NC}"
launchctl load "$HOME/Library/LaunchAgents/com.marco.moneyapp.backup.plist"

# Test the backup script
echo -e "${YELLOW}Testing backup script...${NC}"
./scripts/backup.sh

echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo -e "${GREEN}Automatic backup will run daily at 9:00 AM${NC}"
echo -e "${GREEN}Backup location: $HOME/Documents/MoneyApp_Backups${NC}"
echo -e "${GREEN}Logs location: $HOME/Library/Logs/MoneyApp${NC}"
echo -e "${GREEN}GitHub repository: https://github.com/XIT3X/MoneyApp.git${NC}"

echo -e "${BLUE}=== Manual Commands ===${NC}"
echo -e "${YELLOW}To run backup manually:${NC} ./scripts/backup.sh"
echo -e "${YELLOW}To stop automatic backup:${NC} launchctl unload ~/Library/LaunchAgents/com.marco.moneyapp.backup.plist"
echo -e "${YELLOW}To start automatic backup:${NC} launchctl load ~/Library/LaunchAgents/com.marco.moneyapp.backup.plist"
echo -e "${YELLOW}To check backup logs:${NC} tail -f ~/Library/Logs/MoneyApp/backup.log" 