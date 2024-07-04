Param(
    [string]$organizationName,          # Your Azure DevOps organization name
    [string]$projectName,               # Your project name
    [string]$libVariableName,           # The name of the library 
    [string]$libVariableParameterName,  # The name of the variable to update
    [string]$patToken,                  # Personal Access Token (PAT)
    [string]$valuetoUpdate,             # The value to update
    [string]$pipelineName,
    [string]$pipelineVariableName
)

# Base64 encode the PAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$patToken"))

function pipelineVariablesUpdate{
    $pipelineurl = "https://vsrm.dev.azure.com/$organizationName/$projectName/_apis/release/releases/?api-version=7.1-preview.8"

    $pipelinelist = Invoke-RestMethod -Uri $pipelineurl -Method Get -Headers @{ Authorization = "Basic $base64AuthInfo" }
    $arr = @()
    foreach ($pipelinelist in $pipelinelist.value) {
        if ($pipelinelist.releaseDefinition.name -eq 'deploying_weatherapp') {
            [int]$id = $pipelinelist.id
            $arr += $id
        }
    }
    if ($arr.Count -eq 0) {
        Write-Error "No releases found with the name 'deploying_weatherapp'"
        return
    }
    $currentReleaseId = $arr[0]
    Write-Output "Release ID: $currentReleaseId"
    $currentReleaseResponse = "https://vsrm.dev.azure.com/$organizationName/$projectName/_apis/release/releases/$currentReleaseId/?api-version=7.1-preview.8"
    Write-Output "URI for fetching release details: $currentReleaseResponse"
    $currentRelease = Invoke-RestMethod -Uri $currentReleaseResponse -Method Get -Headers @{
        Authorization = "Basic $base64AuthInfo"
        Accept = "application/json; api-version=7.1-preview.8"
    }
    $keepForever = $currentRelease.keepForever
    Write-Output "Current keepForever value: $keepForever"
    $variableBody = @{
        keepForever = $keepForever
        variables = @{
            $pipelineVariableName = @{
                value = $valuetoUpdate
                isSecret = $false
            }
        }
    } | ConvertTo-Json -Depth 100
    Write-Output "Variable Body: $variableBody"
    $updateReponse = Invoke-RestMethod -Uri $uri -Method Patch -Headers @{
        Authorization = "Basic $base64AuthInfo"
        "Content-Type" = "application/json"
        Accept = "application/json; api-version=7.1-preview.8"
    } -Body $variableBody
    $updateReponse.variables
    Write-Host "Pipeline Variable: $pipelineVariableName  updated successfully with value: $valuetoUpdate"
}
try {   
    # API call to get the id of Library Variable
    $libvariableuri = "https://dev.azure.com/$organizationName/$projectName/_apis/distributedtask/variablegroups/?api-version=6.0-preview.2"
    $response = Invoke-RestMethod -Uri $libvariableuri -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

    # Check if the variable group exists
    $libVarGroup = $response.value | Where-Object { $_.name -eq $libVariableName }
    if (-not $libVarGroup) {
        throw "Library variable group '$libVariableName' not found."
    }

    $libVarGroupId = $libVarGroup.id

    # Get the existing variable group
    $uri = "https://dev.azure.com/$organizationName/$projectName/_apis/distributedtask/variablegroups/$libVarGroupId"+"?api-version=6.0-preview.2"
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

    # Update the variable value
    $response.variables.$libVariableParameterName.value = $valuetoUpdate

    # Update the variable group
    $json = $response | ConvertTo-Json -Depth 100
    Invoke-RestMethod -Uri $uri -Method Put -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo); "Content-Type"="application/json"} -Body $json

    Write-Host "Variable group updated successfully with value: $valuetoUpdate"
    pipelineVariablesUpdate
    exit 0
}
catch {
    Write-Host "Variable group updated un-successfully"
    Write-Host "⚠️ Error: $($_.Exception.Message)"
    exit 1
}
