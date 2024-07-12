param(
    [string]$appRegistrationName,
    [string]$appRegistrationClientSecretName,
    [string]$keyVaultName,
    [string]$resourceGroupName,
    [string]$DataBaseName,
    [string]$DataBasePassword,
    [string]$DataBaseServerLink,
    [string]$DataBaseUserName
)
$tenantId=az account list --query "[?contains(user.name, 'kollichaitanya2024@gmail.com')].tenantId" --output tsv
$appId=az ad app create --display-name $appRegistrationName --query appId --output tsv
$objectId=az ad app show --id $appId --query id --output tsv
$appRegServicePrincipleObjectId=az ad sp create --id $appId --query id --output tsv
Write-Host "App service and service principle created successfully"
$clientSecretValue=az ad app credential reset --id $objectId --append --display-name $appRegistrationClientSecretName --end-date '2024-12-31' --query password --output tsv

[string]$subscriptionId=az account list --query "[?contains(user.name, 'kollichaitanya2024@gmail.com')].id" --output tsv

[string]$scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"
az role assignment create --role "Key Vault Secrets User" --assignee-object-id $appRegServicePrincipleObjectId --scope $scope --assignee-principal-type ServicePrincipal

az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientSecret" --value $clientSecretValue
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationTenantId" --value $tenantId
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientId" --value $appId

az keyvault secret set --vault-name $keyVaultName --name "DataBaseName" --value $DataBaseName
az keyvault secret set --vault-name $keyVaultName --name "DataBasePassword" --value $  
az keyvault secret set --vault-name $keyVaultName --name "DataBaseServerLink" --value $DataBaseServerLink
az keyvault secret set --vault-name $keyVaultName --name "DataBaseUserName" --value $DataBaseUserName

Write-Host "Key Vault values updated"