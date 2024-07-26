Param(
    [string]$organizationName,          
    [string]$projectName,
    [string]$pipelineName,
    [string]$variableName,
    [string]$variableValue,
    [string]$patToken,
    [string]$pipelineId
)

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$patToken"))

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

$body = @{
    variables = @{
        $variableName = @{
            value = $variableValue
        }
    }
} | ConvertTo-Json

$url = "https://dev.azure.com/$organizationName/$projectName/_apis/pipelines/$pipelineId/runs/$latestRunId"+"?api-version=6.0"
Write-Host "Update URL: $url"

try {
    $response = Invoke-RestMethod -Uri $url -Method Put -Body $body -ContentType "application/json" -Headers @{
        Authorization = "Basic $base64AuthInfo"
    }
    Write-Host "Response: $($response | ConvertTo-Json -Depth 10)"
} catch {
    Write-Error "Failed to update variable: $_"
    exit 1
}
