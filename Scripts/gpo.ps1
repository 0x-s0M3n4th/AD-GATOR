Import-Module GroupPolicy

# Create GPOs
$gpo1 = New-GPO -Name "Kurukshetra-Lab-RelaxedSecurity" -ErrorAction SilentlyContinue
$gpo2 = New-GPO -Name "Hastinapur-SecureBaseline" -ErrorAction SilentlyContinue
$gpo3 = New-GPO -Name "Indraprastha-WorkstationPolicy" -ErrorAction SilentlyContinue

# Link GPOs directly (no Get-GPLink check needed)
New-GPLink -Name "Kurukshetra-Lab-RelaxedSecurity" -Target "DC=kurukshetra,DC=local" -Enforced Yes -ErrorAction SilentlyContinue

New-GPLink -Name "Hastinapur-SecureBaseline" -Target "OU=Hastinapur,DC=kurukshetra,DC=local" -ErrorAction SilentlyContinue

New-GPLink -Name "Indraprastha-WorkstationPolicy" -Target "OU=Indraprastha,DC=kurukshetra,DC=local" -ErrorAction SilentlyContinue
