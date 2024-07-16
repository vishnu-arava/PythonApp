Param(
    [string]$organizationName,          
    [string]$projectName,
    [string]$pipelineId,
    [string]$variableName,
    [string]$variableValue,
    [string]$patToken
)

function Install-AzDevOpsCLI {
    Write-Host "Checking if Azure DevOps CLI is installed..."
    if (-not (Get-Command "az" -ErrorAction SilentlyContinue)) {
        Write-Host "Azure DevOps CLI not found. Installing..."
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://aka.ms/installazurecliwindows')
        az extension add --name azure-devops
    }
}
function Authenticate {
    Write-Host "Authenticating to Azure DevOps..."
    az devops configure --defaults organization=https://dev.azure.com/$organizationName project=$projectName
    az devops login --organization https://dev.azure.com/$organizationName --token $patToken
}


function Update-PipelineVariable {
    Write-Host "Updating pipeline variable..."
    az pipelines variable update --name $variableName --pipeline-id $pipelineId --value $variableValue
    Write-Host "Pipeline variable updated successfully."
}

Install-AzDevOpsCLI
Authenticate
Update-PipelineVariable
