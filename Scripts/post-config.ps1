Start-Sleep -Seconds 60

Import-Module ActiveDirectory

# Core structure first
powershell.exe -File "C:\ADSetup\ou-structure.ps1"

# Identity setup
powershell.exe -File "C:\ADSetup\users.ps1"
powershell.exe -File "C:\ADSetup\groups.ps1"
powershell.exe -File "C:\ADSetup\memberships.ps1"
powershell.exe -File "C:\ADSetup\service-accounts.ps1"

# Move objects into OUs
powershell.exe -File "C:\ADSetup\move-objects.ps1"

# Infrastructure services
powershell.exe -File "C:\ADSetup\adcs.ps1"
powershell.exe -File "C:\ADSetup\shares.ps1"

# GPOs last
powershell.exe -File "C:\ADSetup\gpo.ps1"

