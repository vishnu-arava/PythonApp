param(
    [string]$appRegistrationName,
    [string]$appRegistrationClientSecretName,
    [string]$keyVaultName,
    [string]$resourceGroupName,
    [string]$tenantId,
    [string]$subscriptionId,
    [string]$dbName,
    [string]$dbPassword,
    [string]$dbServerLink,
    [string]$dbUserName,
    [string]$patPowershell
)
[string]$appId=az ad app create --display-name $appRegistrationName --query appId --output tsv
[string]$objectId=az ad app show --id $appId --query id --output tsv
[string]$appRegServicePrincipleObjectId=az ad sp create --id $appId --query id --output tsv
Write-Host "App service and service principle created successfully"
[string]$clientSecretValue=az ad app credential reset --id $objectId --append --display-name $appRegistrationClientSecretName --end-date '2024-12-31' --query password --output tsv

[string]$scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"
az role assignment create --role "Key Vault Secrets User" --assignee-object-id $appRegServicePrincipleObjectId --scope $scope --assignee-principal-type ServicePrincipal
 
az keyvault set-policy --name $keyVaultName --object-id $appRegServicePrincipleObjectId --secret-permissions get, list

az keyvault secret list --vault-name $keyVaultName
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientSecret" --value $clientSecretValue
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationTenantId" --value $tenantId
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientId" --value $appId
az keyvault secret set --vault-name $keyVaultName --name "DataBaseName" --value $dbName
az keyvault secret set --vault-name $keyVaultName --name "DataBasePassword" --value $dbPassword
az keyvault secret set --vault-name $keyVaultName --name "DataBaseServerLink" --value $dbServerLink
az keyvault secret set --vault-name $keyVaultName --name "DataBaseUserName" --value $dbUserName
az keyvault secret set --vault-name $keyVaultName --name "PAT-Powershell" --value $patPowershell
Write-Host "Key Vault values updated"