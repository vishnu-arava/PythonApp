Param(
    [string]$organizationName = "venkatachaitanya095",
    [string]$projectName = "PythonProjects",
    [string]$patToken = "6zhjnvr62htkgggcfsk2krlepb37spctasuj6efca5t7p3cugp5a",
    [string]$serviceConnectionName = "testserviceconnection1",
    [string]$servicePublicIp = "13.89.101.74",
    [string]$userName = "username",
    [string]$password = "password",
    [string]$libVariableName ="vm_weatherapp_publicip",
    [string]$libVariableParameterName = "ssh_serviceconnection"
)
# Encode PAT for authorization
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($patToken)"))
# Define the URL to fetch the project details
$projectApiUrl = "https://dev.azure.com/$organizationName/_apis/projects/$projectName"+"?api-version=6.0"
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
    exit 0
}
catch {
    Write-Host "Organization Name: $organizationName"
    Write-Host "Project Name: $projectName"
    Write-Host "Service Connection Name: $serviceConnectionName"
    Write-Host "Service Public IP: $servicePublicIp"
    Write-Host "Username: $userName"
    Write-Host "Password: $password"
    Write-Host "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    exit 1
}