# Define color codes and exit message
$colors = @{
    Error = "Red"
    Pass = "Green"
    Info = "Yellow"
    Description = "Yellow"
    Exit = "White"
}
$ExitMessage = "Press Enter to exit"

# Define the folder path for logs in AppData
$appDataPath = [System.Environment]::GetFolderPath('ApplicationData')
$logFolderPath = [System.IO.Path]::Combine($appDataPath, "ScriptLogs")
$logFilePath = [System.IO.Path]::Combine($logFolderPath, "Anti-Fed Log.txt")

# ASCII Art and GitHub Information
$asciiArt = @"
    ____  _                          __   ___          __  _       ______         __
   / __ \(_)_____________  _________/ /  /   |  ____  / /_(_)     / ____/__  ____/ /
  / / / / / ___/ ___/ __ \/ ___/ __  /  / /| | / __ \/ __/ /_____/ /_  / _ \/ __  /
 / /_/ / (__  ) /__/ /_/ / /  / /_/ /  / ___ |/ / / / /_/ /_____/ __/ /  __/ /_/ /
/_____/_/____/\___/\____/_/   \__,_/  /_/  |_/_/ /_/\__/_/     /_/    \___/\__,_/
"@
$githubText = "GitHub: DeadDove13"

# Display ASCII art, GitHub information, and script description
Write-Host $asciiArt -ForegroundColor DarkGreen
Write-Host $githubText -ForegroundColor White
Write-Host "This script removes cache files from Discord and flushes your DNS if someone sends you some nasty shit." -ForegroundColor $colors.Description

# Helper function to create the log folder and file if they do not exist
function Ensure-LogFileExists {
    if (-Not (Test-Path -Path $logFolderPath)) {
        New-Item -Path $logFolderPath -ItemType Directory -Force | Out-Null
    }
    if (-Not (Test-Path -Path $logFilePath)) {
        New-Item -Path $logFilePath -ItemType File -Force | Out-Null
    }
}

# Function to log actions to a file
function Log-Action {
    param (
        [string]$Message
    )
    try {
        Ensure-LogFileExists
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $logFilePath -Value "$timestamp - $Message"
    }
    catch {
        Write-Host "Error while logging: $_" -ForegroundColor $colors.Error
    }
}

# Function to handle logging and status messages
function Write-Message {
    param (
        [string]$Message,
        [string]$Color = $colors.Info
    )
    Write-Host $Message -ForegroundColor $Color
    Log-Action $Message
}

# Function to ensure Discord is closed
function Ensure-DiscordClosed {
    $discordProcess = Get-Process -Name discord -ErrorAction SilentlyContinue
    if ($discordProcess) {
        Write-Message "Closing Discord..." $colors.Info
        Stop-Process -Name discord -Force
    }
    else {
        Write-Message "Discord is not running." $colors.Info
    }
}

# Function to flush DNS cache
function Flush-DNS {
    try {
        Write-Message "Flushing the DNS cache..." $colors.Info
        ipconfig /flushdns | Out-Null
        Write-Message "Successfully flushed the DNS cache." $colors.Pass
    }
    catch {
        Write-Message "Failed to flush the DNS cache: $_" $colors.Error
    }
}

# Function to change MAC address temporarily
function Change-MACAddress {
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]$Adapter
    )
    try {
        $newMac = "02" + ((Get-Random -Minimum 0 -Maximum 255).ToString("X2")) + ((Get-Random -Minimum 0 -Maximum 255).ToString("X2")) + ((Get-Random -Minimum 0 -Maximum 255).ToString("X2"))
        Write-Message "Changing MAC address of adapter: $($Adapter.Name) to $newMac" $colors.Info

        # Set new MAC address in the registry
        $adapterKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\"
        $adapterConfig = Get-NetAdapter | Where-Object { $_.Name -eq $Adapter.Name }
        $regPath = ($adapterKey + ($adapterConfig.InterfaceIndex.ToString("D4"))).TrimEnd()
        Set-ItemProperty -Path $regPath -Name "NetworkAddress" -Value $newMac

        Toggle-NetworkAdapter -Adapter $Adapter
    }
    catch {
        Write-Message "Failed to change MAC address: $_" $colors.Error
    }
}

# Function to disable and enable network adapter to force IP change
function Toggle-NetworkAdapter {
    param (
        [Parameter(Mandatory = $true)]
        [Microsoft.Management.Infrastructure.CimInstance]$Adapter
    )
    try {
        Write-Message "Disabling network adapter: $($Adapter.Name)" $colors.Info
        Disable-NetAdapter -Name $Adapter.Name -Confirm:$false -ErrorAction Stop
        Start-Sleep -Seconds 5

        Write-Message "Enabling network adapter: $($Adapter.Name)" $colors.Info
        Enable-NetAdapter -Name $Adapter.Name -Confirm:$false -ErrorAction Stop
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Message "Failed to disable/enable network adapter: $_" $colors.Error
    }
}

# Function to get the active network adapter
function Get-ActiveAdapter {
    try {
        Write-Message "Searching for an active network adapter..." $colors.Info
        $adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' -and $_.InterfaceDescription -notlike '*Loopback*' }
        
        if (-not $adapter) {
            Write-Message "No active network adapter found." $colors.Error
            return $null
        } else {
            Write-Message "Active network adapter found: $($adapter.Name)" $colors.Info
            return $adapter
        }
    }
    catch {
        Write-Message "Failed to get active network adapter: $_" $colors.Error
        return $null
    }
}

# Function to renew IP configuration
function Renew-IPConfig {
    $adapter = Get-ActiveAdapter
    if (-not $adapter) {
        Write-Message "Cannot proceed with IP renewal without an active network adapter." $colors.Error
        return
    }
    
    Change-MACAddress -Adapter $adapter

    try {
        Write-Message "Releasing current IP configuration..." $colors.Info
        ipconfig /release | Out-Null
        Start-Sleep -Seconds 5

        Write-Message "Requesting a new IP configuration..." $colors.Info
        ipconfig /renew | Out-Null
        Start-Sleep -Seconds 5

        $newIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike 'Loopback' -and $_.IPAddress -notmatch '^169\.254' -and $_.IPAddress -notmatch '^127' }).IPAddress
        if (-not $newIP) {
            Write-Message "No valid internal IP address found." $colors.Error
        } else {
            Write-Message "Successfully renewed IP configuration. New IP address: $newIP" $colors.Pass
        }
    }
    catch {
        Write-Message "An unexpected error occurred during IP renewal: $_" $colors.Error
    }
}

# Function to clear Discord cache
function Clear-DiscordCache {
    Ensure-DiscordClosed
    $roamingPath = [System.IO.Path]::Combine($appDataPath, "discord", "Cache", "Cache_Data")
    if (-Not (Test-Path -Path $roamingPath)) {
        Write-Message "The Discord Cache_Data folder does not exist at: $roamingPath" $colors.Error
        return
    }
    try {
        $cacheFiles = Get-ChildItem -Path $roamingPath -Recurse
        if ($cacheFiles.Count -eq 0) {
            Write-Message "No cache files found to delete." $colors.Info
        }
        else {
            foreach ($file in $cacheFiles) {
                try {
                    if ($file.PSIsContainer -eq $false) {
                        $file.Attributes = 'Normal'
                        Remove-Item -Path $file.FullName -Force -Recurse
                        Write-Message "Deleted: $($file.FullName)" $colors.Pass
                    }
                }
                catch {
                    Write-Message "Failed to delete: $($file.FullName) - $_" $colors.Error
                }
            }
        }
        Write-Message "Successfully cleared the Discord Cache_Data folder." $colors.Pass
    }
    catch {
        Write-Message "An error occurred while processing the folder: $_" $colors.Error
    }
}

# Function to display logs summary
function Tidy-Output {
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "            Script Logs Summary              " -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "Log folder created at: $logFolderPath" -ForegroundColor Green
    Write-Host "Log file created at: $logFilePath" -ForegroundColor Green

    if (Test-Path -Path $logFilePath) {
        Write-Host "Opening log file..." -ForegroundColor $colors.Info
        Invoke-Item -Path $logFilePath  # Open the log file
    }
    else {
        Write-Host "Log file not found. No logs available to display." -ForegroundColor $colors.Error
    }

    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
}

# Main user input loop
do {
    $choice = Read-Host "Press 1 to clear Discord cache, 2 to flush DNS, 3 to renew IP config, 4 for all actions, 9 for logs or 0 to close"
    switch ($choice) {
        "1" { Clear-DiscordCache }
        "2" { Flush-DNS }
        "3" { Renew-IPConfig }
        "4" {
            Clear-DiscordCache
            Flush-DNS
            Renew-IPConfig
        }
        "9" { Tidy-Output }
        "0" {
            Write-Message "Exiting the script." $colors.Exit
            break
        }
        default { Write-Host "B R U H!!! Invalid input. Please try again." -ForegroundColor $colors.Error }
    }
} while ($true)

# Prompt to exit
Read-Host -Prompt $ExitMessage
