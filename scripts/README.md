# MoneyApp Automatic Backup System

This directory contains scripts for automatic backup and GitHub synchronization of your MoneyApp project.

## Files

- `backup.sh` - Main backup script that creates local backups and syncs to GitHub
- `setup_auto_backup.sh` - Setup script to install automatic backup
- `com.marco.moneyapp.backup.plist` - LaunchAgent configuration for automatic execution

## Setup Instructions

### 1. Install Automatic Backup

Run the setup script to install automatic backup:

```bash
./scripts/setup_auto_backup.sh
```

This will:
- Create necessary directories
- Install the LaunchAgent for automatic execution
- Test the backup functionality
- Set up daily backups at 9:00 AM

### 2. Manual Backup

To run a backup manually:

```bash
./scripts/backup.sh
```

### 3. Manage Automatic Backup

**Stop automatic backup:**
```bash
launchctl unload ~/Library/LaunchAgents/com.marco.moneyapp.backup.plist
```

**Start automatic backup:**
```bash
launchctl load ~/Library/LaunchAgents/com.marco.moneyapp.backup.plist
```

**Check backup logs:**
```bash
tail -f ~/Library/Logs/MoneyApp/backup.log
```

## What the Backup Does

1. **Local Backup**: Creates a compressed archive in `~/Documents/MoneyApp_Backups/`
2. **Git Operations**: 
   - Adds all changes to git
   - Commits with timestamp
   - Pushes to GitHub repository
3. **Cleanup**: Removes old backups (keeps last 10)

## Backup Locations

- **Local Backups**: `~/Documents/MoneyApp_Backups/`
- **Logs**: `~/Library/Logs/MoneyApp/`
- **GitHub**: https://github.com/XIT3X/MoneyApp.git

## GitHub Actions

The project also includes GitHub Actions for automatic CI/CD:

- **File**: `.github/workflows/ios-build.yml`
- **Triggers**: Push to main/develop branches, pull requests
- **Actions**: 
  - Build iOS project
  - Run tests
  - Create archive
  - Upload artifacts
  - Create backup archives

## Configuration

You can modify the backup schedule by editing `com.marco.moneyapp.backup.plist`:

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>9</integer>
    <key>Minute</key>
    <integer>0</integer>
</dict>
```

## Troubleshooting

1. **Check if service is running:**
   ```bash
   launchctl list | grep moneyapp
   ```

2. **View recent logs:**
   ```bash
   tail -20 ~/Library/Logs/MoneyApp/backup.log
   ```

3. **Check error logs:**
   ```bash
   tail -20 ~/Library/Logs/MoneyApp/backup_error.log
   ```

4. **Reinstall service:**
   ```bash
   launchctl unload ~/Library/LaunchAgents/com.marco.moneyapp.backup.plist
   ./scripts/setup_auto_backup.sh
   ``` 