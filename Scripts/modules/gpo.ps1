Import-Module GroupPolicy

$root = "DC=kurukshetra,DC=local"

function Create-GPO-Link {
    param($name, $target)

    if (-not (Get-GPO -Name $name -ErrorAction SilentlyContinue)) {
        New-GPO -Name $name
    }

    if (-not (Get-GPLink -Target $target | Where-Object {$_.DisplayName -eq $name})) {
        New-GPLink -Name $name -Target $target
    }
}

# Kurukshetra (Attack Zone)
Create-GPO-Link "Kurukshetra-Lab-RelaxedSecurity" "OU=Kurukshetra,$root"

# Hastinapur (Secure Core)
Create-GPO-Link "Hastinapur-SecureBaseline" "OU=Hastinapur,$root"

# Indraprastha (Workstations)
Create-GPO-Link "Indraprastha-WorkstationPolicy" "OU=Indraprastha,$root"
