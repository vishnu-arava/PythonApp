# Define your parameters
Param(
$organization,
$project,
$patToken,
$BasePipelineName,
$ReleaseVarName,
$ReleaseVarValue
)
# Encode the PAT token
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($patToken)"))

# Get the releases
$id = @()
$ReleaseUrl = "https://vsrm.dev.azure.com/$organization/$project/_apis/Release/releases"+"?api-version=7.1-preview.2"
$ReleasesListResponse = Invoke-RestMethod -Uri $ReleaseUrl -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
foreach ($release in $ReleasesListResponse.value) {
    if ($release.releaseDefinition.name -eq $BasePipelineName) {
        $id += $release.id
    }
}

if ($id.Count -eq 0) {
    Write-Error "No releases found for the pipeline '$BasePipelineName'"
    exit 1
}

$latestReleaseId = $id[0]
$latestReleaseUrl = "https://vsrm.dev.azure.com/$organization/$project/_apis/Release/releases/$latestReleaseId"+"?api-version=7.1-preview.2"
$LatestReleaseResponse = Invoke-RestMethod -Uri $latestReleaseUrl -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
$LatestReleaseResponse.variables.$ReleaseVarName.value = $ReleaseVarValue

$jsonbody = $LatestReleaseResponse | ConvertTo-Json -Depth 100

# Update pipeline variable group in the latest release
Invoke-RestMethod -Uri $latestReleaseUrl -Method Put -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo); "Content-Type"="application/json"} -Body $jsonbody