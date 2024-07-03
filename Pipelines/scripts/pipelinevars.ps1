$uri = 'https://vsrm.dev.azure.com/venkatachaitanya095/PythonProjects/_apis/release/releases/?api-version=7.1-preview.8'
$pat = 'at5imguzafuqfpchwzz6wbjnp7tkbdcdkglxccreuqwr2ht7fnzq'
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))


$releases = Invoke-RestMethod -Uri $uri -Method Get -Headers @{ Authorization = "Basic $base64AuthInfo" }


$arr = @()


foreach ($release in $releases.value) {
    if ($release.releaseDefinition.name -eq 'deploying_weatherapp') {
        [int]$id = $release.id
        $arr += $id
    }
}


if ($arr.Count -eq 0) {
    Write-Error "No releases found with the name 'deploying_weatherapp'"
    return
}


$releaseId = $arr[0]
Write-Output "Release ID: $releaseId" 


$uri = "https://vsrm.dev.azure.com/venkatachaitanya095/PythonProjects/_apis/release/releases/$releaseId/?api-version=7.1-preview.8"
Write-Output "URI for fetching release details: $uri"

$currentRelease = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
    Authorization = "Basic $base64AuthInfo"
    Accept = "application/json; api-version=7.1-preview.8"
}

$keepForever = $currentRelease.keepForever
Write-Output "Current keepForever value: $keepForever"

#$uri = "https://vsrm.dev.azure.com/venkatachaitanya095/PythonProjects/_apis/release/releases/$releaseId/?api-version=7.1-preview.8"
$uri = "https://vsrm.dev.azure.com/venkatachaitanya095/PythonProjects/_apis/release/definitions/7"
Write-Output "URI for updating release: $uri"
[string]$valuetochange = 'publicip' 

$variableBody = @{
    keepForever = $keepForever
    variables = @{
        $valuetochange = @{
            value = "changed"
        }
    }
} | ConvertTo-Json -Depth 100
Write-Output "Variable Body: $variableBody"

$r = Invoke-RestMethod -Uri $uri -Method Patch -Headers @{
    Authorization = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
    Accept = "application/json; api-version=7.1-preview.4"
} -Body $variableBody

$r.variables