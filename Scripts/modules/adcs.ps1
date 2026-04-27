# Install ADCS Role
Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools

# Configure Enterprise CA
Install-AdcsCertificationAuthority `
-CAType EnterpriseRootCA `
-CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
-KeyLength 2048 `
-HashAlgorithmName SHA256 `
-ValidityPeriod Years `
-ValidityPeriodUnits 5 `
-CACommonName "KURUKSHETRA-CA" `
-Force
