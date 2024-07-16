Param(
    [string]$organizationName,          
    [string]$projectName,
    [string]$pipelineId,
    [string]$variableName,
    [string]$variableValue,
    [string]$patToken
)

# Function to authenticate to Azure DevOps
function Authenticate {
    Write-Host "Authenticating to Azure DevOps..."
    az devops configure --defaults organization=https://dev.azure.com/$organizationName project=$projectName
    az devops login --organization https://dev.azure.com/$organizationName --token $patToken
}

# Function to update pipeline variable
function Update-PipelineVariable {
    Write-Host "Updating pipeline variable..."
    az pipelines variable update --name $variableName --pipeline-id $pipelineId --value $variableValue
    Write-Host "Pipeline variable updated successfully."
}

# Main script execution
try {
    Authenticate
    Update-PipelineVariable
} catch {
    Write-Error "Script failed: $_"
    exit 1
}
