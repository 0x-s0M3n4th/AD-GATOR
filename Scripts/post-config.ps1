Start-Sleep -Seconds 60

Import-Module ActiveDirectory

# Core structure first
powershell.exe -File "C:\ADSetup\modules\ou-structure.ps1"

# Identity setup
powershell.exe -File "C:\ADSetup\modules\users.ps1"
powershell.exe -File "C:\ADSetup\modules\groups.ps1"
powershell.exe -File "C:\ADSetup\modules\memberships.ps1"
powershell.exe -File "C:\ADSetup\modules\service-accounts.ps1"

# Move objects into OUs
powershell.exe -File "C:\ADSetup\modules\move-objects.ps1"

# Infrastructure services
powershell.exe -File "C:\ADSetup\modules\adcs.ps1"
powershell.exe -File "C:\ADSetup\modules\shares.ps1"

# GPOs last
powershell.exe -File "C:\ADSetup\modules\gpo.ps1"

# Cleanup
Unregister-ScheduledTask -TaskName "PostADConfig" -Confirm:$false
