Import-Module ActiveDirectory

function Create-OU {
    param($name, $path)

    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$name'" -SearchBase $path -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $name -Path $path
    }
}

# Root DN
$root = "DC=kurukshetra,DC=local"

# Top OUs
Create-OU "Hastinapur" $root
Create-OU "Indraprastha" $root
Create-OU "Kurukshetra" $root
Create-OU "Dwaraka" $root

# Sub OUs
Create-OU "DomainControllers" "OU=Hastinapur,$root"
Create-OU "Servers" "OU=Hastinapur,$root"

Create-OU "Workstations" "OU=Indraprastha,$root"
Create-OU "Users" "OU=Indraprastha,$root"

Create-OU "VulnerableMachines" "OU=Kurukshetra,$root"
Create-OU "ServiceAccounts" "OU=Kurukshetra,$root"

Create-OU "SecurityTools" "OU=Dwaraka,$root"
