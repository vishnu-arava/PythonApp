Param(
    [string]$organizationName,          # Your Azure DevOps organization name
    [string]$projectName,               # Your project name
    [string]$libVariableName,           # The name of the library 
    [string]$libVariableParameterName,  # The name of the variable to update
    [string]$patToken,                  # Personal Access Token (PAT)
    [string]$value
)
# Base64 encode the PAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$patToken"))
try {
    # API call to get the id of Library Variable
    $libvariableuri = "https://dev.azure.com/$organizationName/$projectName/_apis/distributedtask/variablegroups/?api-version=6.0-preview.2"
    $response = Invoke-RestMethod -Uri $libvariableuri -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    $libVarGroupId = ($response.value | Where-Object { $_.name -eq $libVariableName }).id
    # Get the existing variable group
    $uri = "https://dev.azure.com/$organizationName/$projectName/_apis/distributedtask/variablegroups/$libVarGroupId"+"?api-version=6.0-preview.2"
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    # Update the variable value
    $response.variables.$libVariableParameterName.value = $value
    # Update the variable group
    $json = $response | ConvertTo-Json -Depth 100
    Invoke-RestMethod -Uri $uri -Method Put -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo); "Content-Type"="application/json"} -Body $json
    Write-Host "Variable group updated successfully with : $value"
    exit 0
}
catch {
    Write-Host "Variable group updated un-successfully"
    "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    exit 1
}