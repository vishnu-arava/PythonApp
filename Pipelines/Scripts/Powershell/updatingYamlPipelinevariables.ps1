Param(
    [string]$organizationName,          
    [string]$projectName,
    [string]$pipelineName,
    [string]$variableName,
    [string]$variableValue,
    [string]$patToken,
    [string]$pipelineId
)

# Base64 encode PAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$patToken"))

# Get the latest run ID
$runUrl = "https://dev.azure.com/$organizationName/$projectName/_apis/pipelines/$pipelineId/runs?api-version=6.0"
Write-Host "Run URL: $runUrl"

try {
    $runResponse = Invoke-RestMethod -Uri $runUrl -Headers @{ Authorization = "Basic $base64AuthInfo" }
    $latestRunId = $runResponse.value[0].id
    Write-Host "Latest Run ID: $latestRunId"
} catch {
    Write-Error "Failed to get latest run ID: $_"
    exit 1
}

# Create the JSON body
$body = @{
    variables = @{
        $variableName = @{
            value = $variableValue
        }
    }
} | ConvertTo-Json

# Define the API URL to update the variable
$url = "https://dev.azure.com/$organizationName/$projectName/_apis/pipelines/$pipelineId/runs/$latestRunId"+"?api-version=6.0"
Write-Host "Update URL: $url"

# Make the API request to update the variable
try {
    $response = Invoke-RestMethod -Uri $url -Method Put -Body $body -ContentType "application/json" -Headers @{
        Authorization = "Basic $base64AuthInfo"
    }
    Write-Host "Response: $($response | ConvertTo-Json -Depth 10)"
} catch {
    Write-Error "Failed to update variable: $_"
    exit 1
}
