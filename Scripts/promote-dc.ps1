Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Install-ADDSForest `
-DomainName "kurukshetra.local" `
-DomainNetbiosName "KURUKSHETRA" `
-InstallDNS `
-SafeModeAdministratorPassword (ConvertTo-SecureString "Admin@123456" -AsPlainText -Force) `
-Force
