Param(
    [string]$organizationName,
    [string]$projectName,
    [string]$patToken,
    [string]$servicePublicIp,
    [string]$userName,
    [string]$password,
    [string]$libVariableName,
    [string]$libVariableParameterName,
    [string]$pipelineName,
    [string]$pipelineVariableName
)
# Encode PAT for authorization
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($patToken)"))
# Define the URL to fetch the project details
$projectApiUrl = "https://dev.azure.com/$organizationName/_apis/projects/$projectName"+"?api-version=6.0"
$serviceConnectionName = "vmServiceConnection($servicePublicIp)"
function pipelineVariablesUpdate {
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
    $currentRelease.variables.$pipelineVariableName.value = $valuetoUpdate
    $variableBody = $currentRelease | ConvertTo-Json -Depth 100
    # Write-Output "Variable Body: $variableBody"
    try {
        $updateReponse = Invoke-RestMethod -Uri $currentReleaseResponse -Method Put -Headers @{
            Authorization = "Basic $base64AuthInfo"
            "Content-Type" = "application/json"
            Accept = "application/json; api-version=7.1-preview.8"
        } -Body $variableBody
        Write-Host $updateReponse.variable
        Write-Host "Pipeline Variable: $pipelineVariableName updated successfully with value: $valuetoUpdate"
    }
    catch {
        Write-Host "⚠️ Error updating pipeline variable: $($_.Exception.Message)"
        exit 1
    }
}
try {
    # Fetch the project details
    $projectResponse = Invoke-RestMethod -Uri $projectApiUrl -Method Get -Headers @{
        Authorization = "Basic $base64AuthInfo"
        "Content-Type" = "application/json"
    }
    # Extract the project ID
    $projectId = $projectResponse.id
    # Define the URL for the service connections API
    $apiUrl = "https://dev.azure.com/$organizationName/$projectName/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
    $apiUrl
    # Define the body for the POST request
    $body = @{
        "name" = $serviceConnectionName
        "type" = "ssh"
        "url" = "ssh://"+$servicePublicIp
        "authorization" = @{
            "scheme" = "UsernamePassword"
            "parameters" = @{
                "username" = $userName
                "password" = $password
            }
        }
        "data" = @{
            "Host" = $servicePublicIp
            "Port" = "22"
        }
        "isShared" = "true"
        "serviceEndpointProjectReferences"= @(
         @{
            "projectReference"= @{
                "id"= $projectId
                "name"= $projectName
             }
            "name" = $serviceConnectionName
         }
        )
    } | ConvertTo-Json -Depth 100
    # Make the API call to create the service connection
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers @{
        Authorization = "Basic $base64AuthInfo"
        "Content-Type" = "application/json"
    } -Body $body
    # Output the response
    $response
    # API call to get the id of Library Variable
    $libvariableuri = "https://dev.azure.com/$organizationName/$projectName/_apis/distributedtask/variablegroups/?api-version=6.0-preview.2"
    $response = Invoke-RestMethod -Uri $libvariableuri -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    $libVarGroupId = ($response.value | Where-Object { $_.name -eq $libVariableName }).id
    # API call to update the value in Library Variables
    $libvariableuri = "https://dev.azure.com/$organizationName/$projectName/_apis/distributedtask/variablegroups/$libVarGroupId"+"?api-version=6.0-preview.2"
    
    $response = Invoke-RestMethod -Uri $libvariableuri -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    # Update the variable value
    $response.variables.$libVariableParameterName.value = $serviceConnectionName
    # Update the variable group
    $json = $response | ConvertTo-Json -Depth 100
    Invoke-RestMethod -Uri $libvariableuri -Method Put -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo); "Content-Type"="application/json"} -Body $json
    Write-Host "Variable group updated successfully with service connection: $serviceConnectionName"
    pipelineVariablesUpdate
    exit 0
}
catch {
    Write-Host "⚠️ Error: $($_.Exception.Message)"
    exit 1
}