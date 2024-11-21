# Discord Cache Cleaner and DNS Flusher

This PowerShell script is designed to help you quickly clear Discord cache files and flush your DNS cache, making it perfect for troubleshooting network issues or freeing up space after a bad encounter. Whether you want to clear only Discord's cache or flush the DNS cache as well, this script gives you an easy way to do so.

## Features

- **Force Close Discord**: The script will check if Discord is running and give you the option to force close it or close it manually.
- **Clear Discord Cache**: After ensuring Discord is closed, the script will delete all cache files located in the Discord Cache_Data folder.
- **Flush DNS Cache**: Optionally, the script can flush your DNS cache to resolve potential connection issues.

## How to Use

1. Download or clone the repository.
2. Open the script in PowerShell.
3. Follow the on-screen instructions:
    - Press `1` to force close Discord and clear the cache.
    - Press `2` to clear the cache and flush the DNS.
    - Press `0` to exit the script.

## Example Output

```bash
Press 1 to force close Discord, or 0 to close it manually: 1
Discord has been force-closed.
Successfully cleared the Discord Cache_Data folder.
Flushing the DNS cache...
Successfully flushed the DNS cache.
