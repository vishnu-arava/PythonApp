# Define your parameters
$organization = "your_organization"                 # Replace with your organization name
$project = "your_project"                           # Replace with your project name
$variableGroupName = "your_variable_group_name"     # Replace with your library variable group name
$variableName = "your_variable_name"                # Replace with your library variable name
$variableValue = "your_public_ip"                   # Replace with your public IP
$patToken = "your_pat_token"                        # Replace with your PAT token
$PipeVariableName = "vmname"                        # Replace with your pipeline variable name
$PipeVariableValue = "vishnuvm"                     # Replace with your pipeline variable value
$BasePipelineName = "your_base_pipeline_name"       # Replace with your base pipeline name

# Encode the PAT token
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($patToken)"))

# Get the variable group ID
$variableGroupsUrl = "https://dev.azure.com/$organization/$project/_apis/distributedtask/variablegroups?api-version=7.1-preview.2"
$variableGroupsList = Invoke-RestMethod -Uri $variableGroupsUrl -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
$MyvariableGroup = $variableGroupsList.value | Where-Object { $_.name -eq $variableGroupName }

if ($null -eq $MyvariableGroup) {
    Write-Error "Variable group '$variableGroupName' not found"
    exit 1
}

$MyvariableGroupId = $MyvariableGroup.id
$MyvariableGroupIdURL = "https://dev.azure.com/$organization/$project/_apis/distributedtask/variablegroups/$MyvariableGroupId?api-version=7.1-preview.2"
$MyvariableGroupIdResponse = Invoke-RestMethod -Uri $MyvariableGroupIdURL -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
$MyvariableGroupIdResponse.variables.$variableName.value = $variableValue

$json = $MyvariableGroupIdResponse | ConvertTo-Json -Depth 100

# Update the library Group variable
Invoke-RestMethod -Uri $MyvariableGroupIdURL -Method Put -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo); "Content-Type"="application/json"} -Body $json
#
#
#
#
#
# Get the releases
$id = @()
$ReleaseUrl = "https://vsrm.dev.azure.com/$organization/$project/_apis/Release/releases?api-version=7.1-preview.2"
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
$latestReleaseUrl = "https://vsrm.dev.azure.com/$organization/$project/_apis/Release/releases/$latestReleaseId?api-version=7.1-preview.2"
$LatestReleaseResponse = Invoke-RestMethod -Uri $latestReleaseUrl -Method Get -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
$LatestReleaseResponse.variables.$PipeVariableName.value = $PipeVariableValue

$jsonbody = $LatestReleaseResponse | ConvertTo-Json -Depth 100

# Update pipeline variable group in the latest release
Invoke-RestMethod -Uri $latestReleaseUrl -Method Put -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo); "Content-Type"="application/json"} -Body $jsonbody