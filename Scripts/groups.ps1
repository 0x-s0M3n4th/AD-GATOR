Import-Module ActiveDirectory

$groups = @("Pandavas","Kauravas")

foreach ($group in $groups) {
    if (-not (Get-ADGroup -Filter {Name -eq $group})) {
        New-ADGroup -Name $group -GroupScope Global
    }
}
