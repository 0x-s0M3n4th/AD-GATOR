Import-Module ActiveDirectory

$root = "DC=kurukshetra,DC=local"

# Move DC
Get-ADComputer "DC-BHISHMA" -ErrorAction SilentlyContinue | 
Move-ADObject -TargetPath "OU=DomainControllers,OU=Hastinapur,$root"

# Move Users
$usersOU = "OU=Users,OU=Indraprastha,$root"

foreach ($u in @("arjuna","bhima","karna","duryodhana","krishna")) {
    Get-ADUser $u -ErrorAction SilentlyContinue | Move-ADObject -TargetPath $usersOU
}

# Move Service Account
Get-ADUser "SQLService" -ErrorAction SilentlyContinue |
Move-ADObject -TargetPath "OU=ServiceAccounts,OU=Kurukshetra,$root"
