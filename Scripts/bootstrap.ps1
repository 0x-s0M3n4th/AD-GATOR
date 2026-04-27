# Create working directory
$base = "C:\ADSetup"
New-Item -ItemType Directory -Path $base -Force

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
