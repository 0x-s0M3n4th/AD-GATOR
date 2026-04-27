# Create directory
New-Item -Path "C:\MahabharataShare" -ItemType Directory -Force

# Create share
New-SmbShare -Name "KurukshetraShare" -Path "C:\MahabharataShare" -FullAccess "Everyone"

# Add weak permissions (intentional)
icacls "C:\MahabharataShare" /grant Everyone:F
