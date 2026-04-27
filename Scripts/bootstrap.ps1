$base = "C:\ADSetup"
New-Item -ItemType Directory -Path $base -Force

# Get current script directory (Azure temp location)
$source = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Copy EVERYTHING including modules
Copy-Item -Path "$source\*" -Destination $base -Recurse -Force

# Verify modules exist
if (!(Test-Path "C:\ADSetup\modules")) {
    Write-Output "Modules folder missing! Exiting..."
    exit 1
}

# Register scheduled task for post-config
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -File C:\ADSetup\post-config.ps1"

$trigger = New-ScheduledTaskTrigger -AtStartup

Register-ScheduledTask `
    -TaskName "PostADConfig" `
    -Action $action `
    -Trigger $trigger `
    -RunLevel Highest `
    -Force

# Run DC promotion
Start-Process powershell.exe `
    -ArgumentList "-ExecutionPolicy Bypass -File C:\ADSetup\promote-dc.ps1" `
    -Wait
