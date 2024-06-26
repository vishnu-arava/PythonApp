Param(
    [string]$organizationName,  # Your Azure DevOps organization name
    [string]$projectName,       # Your project name
    [string]$libVarGroupId,     # The ID of the variable group
    [string]$libVariableName,   # The name of the variable to update
    [string]$patToken,           # Personal Access Token (PAT)
    [string]$publicIpValue
)
# Base64 encode the PAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$patToken"))
# Get the existing variable group
$uri = "https://dev.azure.com/$organizationName/$projectName/_apis/distributedtask/variablegroups/$libVarGroupId"+"?api-version=6.0-preview.2"
try {
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    # Update the variable value
    $response.variables.$libVariableName.value = $publicIpValue
    # Update the variable group
    $json = $response | ConvertTo-Json -Depth 100
    Invoke-RestMethod -Uri $uri -Method Put -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo); "Content-Type"="application/json"} -Body $json
    Write-Host "Variable group updated successfully with public IP: $publicIpValue"
    exit 0
}
catch {
    Write-Host "Variable group updated un-successfully"
    "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    exit 1
}