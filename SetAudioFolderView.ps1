# Requires elevation (Run as Administrator)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script requires administrator privileges. Please run PowerShell as Administrator."
    exit
}

# Registry path for the Audio folder template
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\{94D6DDCC-4A68-4175-A374-BD584A510B78}\PropertyViewDefault"

# Define the columns we want (in order)
$columns = @(
    "System.ItemNameDisplay",              # Name
    "System.ItemTypeText",                 # Type
    "System.Size",                         # Size
    "System.Audio.Bitrate",               # Bitrate
    "System.DateCreated",                 # Date Created
    "System.DateModified"                 # Date Modified
)

try {
    # Create the PropertyViewDefault key if it doesn't exist
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Convert column list to proper format
    $columnData = [byte[]](@())
    foreach ($column in $columns) {
        $columnBytes = [System.Text.Encoding]::Unicode.GetBytes($column + [char]0)
        $columnData += $columnBytes
    }

    # Set the registry value
    Set-ItemProperty -Path $regPath -Name "Contents" -Value $columnData -Type Binary

    # Force a refresh of the shell
    Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
    Start-Process "explorer.exe"

    Write-Host "Successfully updated Audio folder template view settings. Explorer has been restarted."
} catch {
    Write-Error "An error occurred: $_"
}