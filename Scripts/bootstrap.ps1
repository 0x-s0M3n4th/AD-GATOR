$base = "C:\ADSetup"
New-Item -ItemType Directory -Path $base -Force

# Copy all scripts from current execution directory to C:\ADSetup
$source = Split-Path -Parent $MyInvocation.MyCommand.Definition
Copy-Item -Path "$source\*" -Destination $base -Recurse -Force

# Register scheduled task
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
