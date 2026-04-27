param(
    [string]$DomainName,
    [string]$Username,
    [string]$Password,
    [string]$DCIP
)

$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)

# Set DNS
Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | ForEach-Object {
    Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses $DCIP
}

# Join Domain
Add-Computer -DomainName $DomainName -Credential $credential -Force -Restart
