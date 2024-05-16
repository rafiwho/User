# Function to log messages to a file
function Log-Message {
    param (
        [string]$Message
    )

    $LogFilePath = "C:\InstallationLog.txt"

    # Log the message to the file
    $Message | Out-File -FilePath $LogFilePath -Append
}

# Check if the script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # If not running as administrator, relaunch as administrator
    Start-Process powershell.exe "-File $($MyInvocation.MyCommand.Path)" -Verb RunAs
    Exit
}

# Logging: Log script start time
Log-Message "Script started at: $(Get-Date)"

# Check if Chocolatey is installed
$chocoInstalled = Test-Path 'C:\ProgramData\chocolatey'

# If Chocolatey is not installed, install it
if (-not $chocoInstalled) {
    Log-Message "Chocolatey package manager not found. Installing Chocolatey..."

    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    
    # Check if Chocolatey installation was successful
    if (Test-Path 'C:\ProgramData\chocolatey') {
        Log-Message "Chocolatey installed successfully."
    } else {
        Log-Message "Failed to install Chocolatey."
        Exit
    }
} else {
    Log-Message "Chocolatey package manager is already installed."
}

# Check if a keyboard is connected
$keyboardConnected = (Get-WmiObject -Class Win32_Keyboard | Measure-Object).Count -gt 0

if ($keyboardConnected) {
    Log-Message "A keyboard is connected."
} else {
    Log-Message "No keyboard found. Please ensure a keyboard is connected."
    Exit
}

# Check if a mouse is connected
$mouseConnected = (Get-WmiObject -Class Win32_PointingDevice | Measure-Object).Count -gt 0

if ($mouseConnected) {
    Log-Message "A mouse is connected."
} else {
    Log-Message "No mouse found. Please ensure a mouse is connected."
    Exit
}

# Check if GCC compiler is installed
$gccInstalled = gcc --version 2>&1 | Select-String "gcc: command not found" -Quiet

# If GCC is not installed, install it
if (-not $gccInstalled) {
    Log-Message "GCC compiler not found. Installing GCC..."

    # Install GCC using Chocolatey package manager
    choco install mingw -y

    # Check if GCC installation was successful
    if ($?) {
        Log-Message "GCC installed successfully."
    } else {
        Log-Message "Failed to install GCC."
    }
} else {
    Log-Message "GCC compiler is already installed."
}

# Logging: Log script end time
Log-Message "Script ended at: $(Get-Date)"
