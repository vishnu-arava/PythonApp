# Define your parameters
$organization               # Replace this with the actual "organisation name" you want to set
$project                    # Replace this with the actual "project name" you want to set
$variableGroupName          # Replace this with the actual "library variable group name" you want to set
$variableName               # Replace this with the actual "library variable name" you want to set
$variableValue              # Replace this with the actual "public IP" you want to set
$patToken

# Encode the PAT token
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($patToken)"))

# Get the variable group ID
$variableGroupUrl = "https://dev.azure.com/$organization/$project/_apis/distributedtask/variablegroups?api-version=7.1-preview.2"
$variableGroupsListResponse = Invoke-RestMethod -Uri $variableGroupUrl -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
$MyvariableGroup = $variableGroupsListResponse.value | Where-Object { $_.name -eq $variableGroupName }

if ($null -eq $MyvariableGroup) {
    Write-Error "Variable group '$variableGroupName' not found"
    exit 1
}

$MyvariableGroupId = $MyvariableGroup.id
$MyvariableGroupIdResponse = "https://dev.azure.com/$organization/$project/_apis/distributedtask/variablegroups/$MyvariableGroupId"+"?api-version=7.1-preview.2"

$MyvariableGroupIdResponse.variables.$variableName.value = $variableValue

$json = $MyvariableGroupIdResponse | ConvertTo-Json -Depth 100

# Update the variable group
$updateUrl = "https://dev.azure.com/$organization/$project/_apis/distributedtask/variablegroups/$MyvariableGroupId"+"?api-version=7.1-preview.2"
Invoke-RestMethod -Uri $uri -Method Put -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo); Content-Type="application/json"} -Body $json

