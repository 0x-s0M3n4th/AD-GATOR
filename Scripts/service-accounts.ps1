Import-Module ActiveDirectory

# Create vulnerable service account
if (-not (Get-ADUser -Filter {SamAccountName -eq "SQLService"})) {

    New-ADUser `
    -Name "SQLService" `
    -SamAccountName "SQLService" `
    -AccountPassword (ConvertTo-SecureString "MYpassword123#" -AsPlainText -Force) `
    -Enabled $true `
    -Description "SQL Service Account Password: MYpassword123#" `
    -PasswordNeverExpires $true

}

# OPTIONAL: Add SPN (Kerberoasting ready)
Set-ADUser SQLService -ServicePrincipalNames @{Add="MSSQLSvc/sql.kurukshetra.local:1433"}
