```ansi
    ____  _                          __   ___          __  _       ______         __
   / __ \(_)_____________  _________/ /  /   |  ____  / /_(_)     / ____/__  ____/ /
  / / / / / ___/ ___/ __ \/ ___/ __  /  / /| | / __ \/ __/ /_____/ /_  / _ \/ __  / 
 / /_/ / (__  ) /__/ /_/ / /  / /_/ /  / ___ |/ / / / /_/ /_____/ __/ /  __/ /_/ /  
/_____/_/____/\___/\____/_/   \__,_/  /_/  |_/_/ /_/\__/_/     /_/    \___/\__,_/   
```

This PowerShell script is designed to manage Discord cache files and network settings efficiently. It provides tools for clearing Discord's cache, flushing your DNS, renewing your IP configuration, and changing the MAC address of your network adapter. This makes it ideal for troubleshooting, freeing up space, or resolving network issues.

---

## Features

- **Force Close Discord**: Ensures Discord is not running before modifying cache files.
- **Clear Discord Cache**: Deletes all cache files from the `Cache_Data` folder to free up space.
- **Flush DNS Cache**: Clears the DNS resolver cache to resolve connection issues.
- **Renew IP Configuration**: Releases and renews your IP address for troubleshooting.
- **Change MAC Address**: Temporarily changes the MAC address of your active network adapter to help with network troubleshooting or privacy concerns.
- **Detailed Logs**: All actions and errors are logged in a dedicated file for review.
- **User-Friendly Menu**: Provides clear options to execute specific actions or combine them.

---

## Warnings

1. **Loss of Cache Data**: Clearing Discord cache removes locally stored data like temporary files. This might result in minor delays when Discord loads these resources again.
2. **Network Disruption**: Flushing DNS, renewing the IP address, or changing the MAC address will temporarily disrupt your internet connection. Ensure no critical downloads or online activities are in progress.
3. **Admin Privileges**: Some operations, such as flushing DNS, renewing IP configuration, or changing the MAC address, may require administrative privileges. Run the script as an administrator to avoid errors.

---

## How It Works

1. **Checks for Discord Process**: The script checks if Discord is running. If it is, it will forcefully close it or allow you to close it manually.
2. **Clears Cache**: Deletes all files in Discord's `Cache_Data` folder to free up space and remove remnants of past activity.
3. **Flushes DNS**: Executes `ipconfig /flushdns` to clear the DNS resolver cache, resolving potential connection issues.
4. **Renews IP Address**: Executes `ipconfig /release` and `ipconfig /renew` to request a new IP configuration from your network.
5. **Changes MAC Address**: Generates a new random MAC address and assigns it to the active network adapter, followed by disabling and re-enabling the adapter to apply the new MAC address. This can help in bypassing certain network restrictions or privacy measures.
6. **Nuke**: Deletes all of your message history as well as your local account data.
7. **Logs Actions**: All actions, including successes and errors, are logged in a file located in `AppData\Roaming\ScriptLogs`.

---

## How to Use

1. **Download or Clone the Repository**: Ensure the script is saved locally.
2. **Run in PowerShell**: Open the script in PowerShell (as administrator for full functionality).
3. **Follow On-Screen Instructions**:
   - Press `1` to clear Discord cache.
   - Press `2` to flush the DNS cache.
   - Press `3` to renew your IP configuration.
   - Press `4` to perform all actions sequentially.
   - Press `5` to NUKE your local account.
   - Press `9` to view log summaries.
   - Press `0` to exit the script.

---

## Author

- GitHub: [DeadDove13](https://github.com/DeadDove13)
