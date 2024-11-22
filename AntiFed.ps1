# Define color codes
$ErrorColour = "Red"
$PassColour = "Green"
$InfoColour = "Yellow"
$ExitMessage = "Press Enter to exit"

# ASCII Art and GitHub Information
$asciiArt = @"
  _____  _                       _                  _   _        ______ ______ _____  
 |  __ \(_)                     | |     /\         | | (_)      |  ____|  ____|  __ \ 
 | |  | |_ ___  ___ ___  _ __ __| |    /  \   _ __ | |_ _ ______| |__  | |__  | |  | |
 | |  | | / __|/ __/ _ \| '__/ _` |   / /\ \ | '_ \| __| |______|  __| |  __| | |  | |
 | |__| | \__ \ (_| (_) | | | (_| |  / ____ \| | | | |_| |      | |    | |____| |__| |
 |_____/|_|___/\___\___/|_|  \__,_| /_/    \_\_| |_|\__|_|      |_|    |______|_____/ 
"@

$githubText = @"
    GitHub: DeadDove13
"@

# Display ASCII art and GitHub information
Write-Host $asciiArt -ForegroundColor Blue
Write-Host $githubText -ForegroundColor White

# Description of the script
$description = @"
This script removes cache files from Discord and flushes your DNS if someone sends you some nasty shit. 
Perfect for clearing up space or handling any unwanted chaos in your connection after a bad encounter. 
"@

Write-Host $description -ForegroundColor Yellow

# Function to log actions to a file
function Log-Action {
    param (
        [string]$Message
    )
    $logFilePath = "$($env:USERPROFILE)\Desktop\ScriptLog.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFilePath -Value "$timestamp - $Message"
}

# Function to check and close Discord
function Ensure-DiscordClosed {
    $discordProcess = Get-Process -Name "Discord" -ErrorAction SilentlyContinue
    if ($discordProcess) {
        Write-Host "Discord is currently running." -ForegroundColor Yellow
        do {
            $choice = Read-Host "Press 1 to force close Discord, or 0 to close it manually"
            
            if ($choice -eq "1") {
                Stop-Process -Name "Discord" -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 3
                Write-Host "Discord has been force-closed." -ForegroundColor $PassColour
                Log-Action "Discord process was force-closed."
                break
            }
            elseif ($choice -eq "0") {
                Write-Host "Please close Discord manually and rerun the script." -ForegroundColor $ErrorColour
                Log-Action "User chose to manually close Discord."
                Read-Host -Prompt $ExitMessage
                Exit
            }
            else {
                Write-Host "B R U H!!! Invalid input. Please try again." -ForegroundColor $ErrorColour
            }
        } while ($true)
    }
    else {
        Write-Host "Discord is not running. Proceeding with cache cleanup." -ForegroundColor $PassColour
    }
}

# Function to flush DNS cache
function Flush-DNS {
    try {
        Write-Host "Flushing the DNS cache..." -ForegroundColor $InfoColour
        ipconfig /flushdns | Out-Null
        Write-Host "Successfully flushed the DNS cache." -ForegroundColor $PassColour
        Log-Action "DNS cache flushed successfully."
    }
    catch {
        Write-Host "Failed to flush the DNS cache: $_" -ForegroundColor $ErrorColour
        Log-Action "Error flushing DNS cache: $_"
    }
}

# Function to renew IP configuration
function Renew-IPConfig {
    try {
        Write-Host "Releasing current IP configuration..." -ForegroundColor $InfoColour
        ipconfig /release | Out-Null
        Write-Host "Requesting a new IP configuration..." -ForegroundColor $InfoColour
        ipconfig /renew | Out-Null
        Write-Host "Successfully renewed IP configuration." -ForegroundColor $PassColour
        Log-Action "IP configuration renewed successfully."
    }
    catch {
        Write-Host "Failed to renew IP configuration: $_" -ForegroundColor $ErrorColour
        Log-Action "Error renewing IP configuration: $_"
    }
}

# Function to clear Discord cache
function Clear-DiscordCache {
    Ensure-DiscordClosed
    $roamingPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('ApplicationData'), "discord", "Cache", "Cache_Data")
    if (-Not (Test-Path -Path $roamingPath)) {
        Write-Host "The Discord Cache_Data folder does not exist at: $roamingPath" -ForegroundColor $ErrorColour
        Log-Action "Cache_Data folder not found at: $roamingPath"
        return
    }
    try {
        $cacheFiles = Get-ChildItem -Path $roamingPath -Recurse
        if ($cacheFiles.Count -eq 0) {
            Write-Host "No cache files found to delete." -ForegroundColor Yellow
            Log-Action "No cache files found in Cache_Data folder."
        }
        else {
            foreach ($file in $cacheFiles) {
                try {
                    if ($file.PSIsContainer -eq $false) {
                        $file.Attributes = 'Normal'
                        Remove-Item -Path $file.FullName -Force -Recurse
                        Write-Host "Deleted: $($file.FullName)" -ForegroundColor $PassColour
                        Log-Action "Deleted cache file: $($file.FullName)"
                    }
                }
                catch {
                    Write-Host "Failed to delete: $($file.FullName) - $_" -ForegroundColor $ErrorColour
                    Log-Action "Failed to delete cache file: $($file.FullName) - $_"
                }
            }
        }
        Write-Host "Successfully cleared the Discord Cache_Data folder." -ForegroundColor $PassColour
        Log-Action "Discord Cache_Data folder cleared successfully."
    }
    catch {
        Write-Host "An error occurred while processing the folder: $_" -ForegroundColor $ErrorColour
        Log-Action "Error clearing Cache_Data folder: $_"
    }
}

# Main user input loop
do {
    $choice = Read-Host "Press 1 to clear Discord cache, 2 to flush DNS, 3 to renew IP config, 4 for all actions, or 0 to close"
    if ($choice -eq "1") {
        Clear-DiscordCache
    }
    elseif ($choice -eq "2") {
        Flush-DNS
    }
    elseif ($choice -eq "3") {
        Renew-IPConfig
    }
    elseif ($choice -eq "4") {
        Clear-DiscordCache
        Flush-DNS
        Renew-IPConfig
    }
    elseif ($choice -eq "0") {
        Write-Host "Exiting the script." -ForegroundColor White
        Log-Action "Script exited by user."
        Exit
    }
    else {
        Write-Host "B R U H!!! Invalid input. Please try again." -ForegroundColor $ErrorColour
    }
} while ($true)

# Prompt to exit
Read-Host -Prompt $ExitMessage
