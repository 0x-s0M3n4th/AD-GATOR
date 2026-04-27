Import-Module ActiveDirectory

$users = @(
    "arjuna",
    "bhima",
    "karna",
    "duryodhana",
    "krishna"   # second domain admin, first DA is default Administrator user.
)

foreach ($user in $users) {
    if (-not (Get-ADUser -Filter {SamAccountName -eq $user})) {
        New-ADUser -Name $user `
        -SamAccountName $user `
        -AccountPassword (ConvertTo-SecureString "Password@123" -AsPlainText -Force) `
        -Enabled $true
    }
}
