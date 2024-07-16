Param(
    [string]$organizationName,          
    [string]$projectName,
    [string]$pipelineId,
    [string]$variableName,
    [string]$variableValue,
    [string]$patToken
)

# Function to check if Azure DevOps CLI is installed and install it if necessary
function Install-AzDevOpsCLI {
    Write-Host "Checking if Azure DevOps CLI is installed..."
    if (-not (Get-Command "az" -ErrorAction SilentlyContinue)) {
        Write-Host "Azure DevOps CLI not found. Installing..."
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://aka.ms/installazurecliwindows')
    }

    # Check if azure-devops extension is installed
    $extensions = az extension list -o table --query "[?name=='azure-devops'].name | [0]"
    if (-not $extensions) {
        Write-Host "Installing azure-devops extension..."
        az extension add --name azure-devops
    }
}

# Function to authenticate to Azure DevOps
function Authenticate {
    Write-Host "Authenticating to Azure DevOps..."
    az devops configure --defaults organization=https://dev.azure.com/$organizationName project=$projectName
    az devops login --organization https://dev.azure.com/$organizationName
}

# Function to update pipeline variable
function Update-PipelineVariable {
    Write-Host "Updating pipeline variable..."
    az pipelines variable update --name $variableName --pipeline-id $pipelineId --value $variableValue
    Write-Host "Pipeline variable updated successfully."
}

# Main script execution
try {
    Install-AzDevOpsCLI
    Authenticate
    Update-PipelineVariable
} catch {
    Write-Error "Script failed: $_"
    exit 1
}
