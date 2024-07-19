param(
    [string]$appRegistrationName,
    [string]$appRegistrationClientSecretName,
    [string]$keyVaultName,
    [string]$resourceGroupName,
    [string]$tenantId,
    [string]$subscriptionId
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
Write-Host "AppRegistrationClientSecret Updated"
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationTenantId" --value $tenantId
Write-Host "AppRegistrationTenantId Updated"
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientId" --value $appId
Write-Host "AppRegistrationClientId Updated"

Write-Host "Key Vault values updated"