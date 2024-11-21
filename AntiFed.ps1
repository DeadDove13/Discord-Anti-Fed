# Define color codes
$ErrorColour = "Red"
$PassColour = "Green"
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
                break
            } elseif ($choice -eq "0") {
                Write-Host "Please close Discord manually and rerun the script." -ForegroundColor $ErrorColour
                Read-Host -Prompt $ExitMessage
                Exit
            } else {
                Write-Host "B R U H!!! Invalid input. Please try again." -ForegroundColor $ErrorColour
            }
        } while ($true)
    } else {
        Write-Host "Discord is not running. Proceeding with cache cleanup." -ForegroundColor $PassColour
    }
}

# Function to flush DNS cache
function Flush-DNS {
    try {
        Write-Host "Flushing the DNS cache..." -ForegroundColor Yellow
        ipconfig /flushdns | Out-Null
        Write-Host "Successfully flushed the DNS cache." -ForegroundColor $PassColour
    } catch {
        Write-Host "Failed to flush the DNS cache: $_" -ForegroundColor $ErrorColour
    }
}

# Function to clear Discord cache
function Clear-DiscordCache {
    # Ensure Discord is closed before continuing
    Ensure-DiscordClosed

    # Find the path to the user's AppData\Roaming\discord\Cache\Cache_Data folder
    $roamingPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('ApplicationData'), "discord", "Cache", "Cache_Data")
    
    # Validate the folder exists
    if (-Not (Test-Path -Path $roamingPath)) {
        Write-Host "The Discord Cache_Data folder does not exist at: $roamingPath" -ForegroundColor $ErrorColour
        return
    }

    # Delete the contents of the Cache_Data folder
    try {
        $cacheFiles = Get-ChildItem -Path $roamingPath -Recurse
        if ($cacheFiles.Count -eq 0) {
            Write-Host "No cache files found to delete." -ForegroundColor Yellow
        } else {
            foreach ($file in $cacheFiles) {
                try {
                    # Only attempt to remove attributes if the item is a file
                    if ($file.PSIsContainer -eq $false) {
                        # Remove read-only attribute if present
                        $file.Attributes = 'Normal'
                        Remove-Item -Path $file.FullName -Force -Recurse
                        Write-Host "Deleted: $($file.FullName)" -ForegroundColor $PassColour
                    }
                } catch {
                    Write-Host "Failed to delete: $($file.FullName) - $_" -ForegroundColor $ErrorColour
                }
            }
        }
        Write-Host "Successfully cleared the Discord Cache_Data folder." -ForegroundColor $PassColour
    } catch {
        Write-Host "An error occurred while processing the folder: $_" -ForegroundColor $ErrorColour
    }
}

# User input loop to run the script or exit
do {
    $choice = Read-Host "Press 1 to clear Discord cache, 2 to clear cache and flush DNS, or 0 to close"

    # Execute based on user's choice
    if ($choice -eq "1") {
        Clear-DiscordCache
    } elseif ($choice -eq "2") {
        Clear-DiscordCache
        Flush-DNS
    } elseif ($choice -eq "0") {
        Write-Host "Exiting the script." -ForegroundColor White
        Exit
    } else {
        Write-Host "B R U H!!! Invalid input. Please try again." -ForegroundColor $ErrorColour
    }
} while ($true)

# Prompt to exit
Read-Host -Prompt $ExitMessage
