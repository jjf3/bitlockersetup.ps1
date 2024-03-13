# Install the Intune PowerShell SDK if not already installed
if (-not (Get-Module -Name Microsoft.Graph.Intune)) {
    Install-Module -Name Microsoft.Graph.Intune -Scope CurrentUser -Force -AllowClobber
}

# Authenticate with your Intune tenant
Connect-MSGraph

# Define BitLocker configuration settings
$bitLockerSettings = @{
    "EncryptionMethod" = "Aes256"
    "PinRequired" = $true
    "RecoveryKey" = $true
    # Add more settings as needed
}

# Create BitLocker configuration profile
$bitLockerProfile = New-IntuneDeviceConfiguration -DisplayName "BitLocker Configuration" -Description "Configures BitLocker settings" -BitLocker $bitLockerSettings

# Get the group containing the new devices
$deviceGroup = Get-IntuneDeviceGroup -DisplayName "New Devices Group"

# Assign the BitLocker configuration profile to the group
Add-IntuneDeviceConfigurationAssignment -AssignTo $deviceGroup.Id -DeviceConfigurationId $bitLockerProfile.Id

# Monitor the deployment status
Write-Host "Monitoring deployment status..."

# Loop until all devices in the group are compliant
do {
    Start-Sleep -Seconds 30
    $complianceStatus = Get-IntuneDeviceConfigurationStatuses -Filter "DeviceId eq ''" | Where-Object { $_.Id -eq $bitLockerProfile.Id }
} while ($complianceStatus.ComplianceState -ne "Compliant")

Write-Host "BitLocker configuration deployed successfully."
