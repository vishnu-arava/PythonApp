Param(
    [string]$organizationName,
    [string]$projectName,
    [string]$patToken,
    [string]$serviceConnectionName,
    [string]$servicePublicIp,
    [string]$userName,
    [string]$password
)

# Encode PAT for authorization
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($patToken)"))

# Define the URL to fetch the project details
$projectApiUrl = "https://dev.azure.com/$organizationName/_apis/projects/$projectName"+"?api-version=6.0"

$projectApiUrl

try {
    # Fetch the project details
    $projectResponse = Invoke-RestMethod -Uri $projectApiUrl -Method Get -Headers @{
        Authorization = "Basic $base64AuthInfo"
        "Content-Type" = "application/json"
    }

    # Extract the project ID
    $projectId = $projectResponse.id

    $projectId

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
        # "projectReference" = @{
        #     "id" = $projectId
        #     "name" = $projectName
        # }
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

    $projectResponse = Invoke-RestMethod -Uri $projectApiUrl -Method Get -Headers @{
        Authorization = "Basic $base64AuthInfo"
        "Content-Type" = "application/json"
    }
    Write-Host "--------------------Project Responce is----------------------------- " 
    $projectResponse
    Write-Host "---------------------------------------------------------------------"
    # Make the API call to create the service connection
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers @{
        Authorization = "Basic $base64AuthInfo"
        "Content-Type" = "application/json"
    } -Body $body

    # Output the response
    $response
}
catch {
    Write-Host "Error creating service connection:"
    Write-Host $_.Exception.Message
    Write-Host "Organization Name: $organizationName"
    Write-Host "Project Name: $projectName"
    Write-Host "Service Connection Name: $serviceConnectionName"
    Write-Host "Service Public IP: $servicePublicIp"
    Write-Host "Username: $userName"
    Write-Host "Password: $password"
    Write-Host "Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
}

    

