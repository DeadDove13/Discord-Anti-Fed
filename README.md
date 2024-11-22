# Discord Cache Cleaner and DNS Flusher

This PowerShell script is designed to manage Discord cache files and network settings efficiently. It provides tools for clearing Discord's cache, flushing your DNS, and renewing your IP configuration, making it ideal for troubleshooting, freeing up space, or resolving network issues.

---

## Features

- **Force Close Discord**: Ensures Discord is not running before modifying cache files.  
- **Clear Discord Cache**: Deletes all cache files from the `Cache_Data` folder to free up space.  
- **Flush DNS Cache**: Clears the DNS resolver cache to resolve connection issues.  
- **Renew IP Configuration**: Releases and renews your IP address for troubleshooting.  
- **Detailed Logs**: All actions and errors are logged in a dedicated file for review.  
- **User-Friendly Menu**: Provides clear options to execute specific actions or combine them.  

---

## Warnings

1. **Loss of Cache Data**: Clearing Discord cache removes locally stored data like temporary files. This might result in minor delays when Discord loads these resources again.
2. **Network Disruption**: Flushing DNS and renewing the IP address will temporarily disrupt your internet connection. Ensure no critical downloads or online activities are in progress.
3. **Admin Privileges**: Some operations, such as flushing DNS or renewing IP configuration, may require administrative privileges. Run the script as an administrator to avoid errors.

---

## How It Works

1. **Checks for Discord Process**: The script checks if Discord is running. If it is, it will forcefully close it or allow you to close it manually.  
2. **Clears Cache**: Deletes all files in Discord's `Cache_Data` folder to free up space and remove remnants of past activity.  
3. **Flushes DNS**: Executes `ipconfig /flushdns` to clear the DNS resolver cache, resolving potential connection issues.  
4. **Renews IP Address**: Executes `ipconfig /release` and `ipconfig /renew` to request a new IP configuration from your network.  
5. **Logs Actions**: All actions, including successes and errors, are logged in a file located in `AppData\Roaming\ScriptLogs`.  

---

## How to Use

1. **Download or Clone the Repository**: Ensure the script is saved locally.  
2. **Run in PowerShell**: Open the script in PowerShell (as administrator for full functionality).  
3. **Follow On-Screen Instructions**:
   - Press `1` to clear Discord cache.  
   - Press `2` to flush the DNS cache.  
   - Press `3` to renew your IP configuration.  
   - Press `4` to perform all actions sequentially.  
   - Press `9` to view log summaries.  
   - Press `0` to exit the script.  

---

## Author

- GitHub: [DeadDove13](https://github.com/DeadDove13)
