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
$runResponse = Invoke-RestMethod -Uri $runUrl -Headers @{ Authorization = "Basic $base64AuthInfo" }
$latestRunId = $runResponse.value[0].id

$body = @{
    variables = @{
        $variableName = @{
            value = $newValue
        }
    }
} | ConvertTo-Json

$url = "https://dev.azure.com/$organizationName/$projectName/_apis/pipelines/$pipelineId/runs/$latestRunId"+"?api-version=6.0"

Write-Host $url

$response = Invoke-RestMethod -Uri $url -Method Patch -Body $body -ContentType "application/json" -Headers @{
    Authorization = "Basic $base64AuthInfo"
}
$response