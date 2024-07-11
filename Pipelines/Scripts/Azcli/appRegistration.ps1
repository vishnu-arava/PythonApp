[string]$appRegistrationName='weatherapp-keyvault'
[string]$appRegistrationClientSecretName='weatherapp-keyvault-client-secret'
[string]$keyVaultName='dkweatherapp-kv-dev'
[string]$resourceGroupName='RG-DEV'
$tenantId=az account list --query "[?contains(user.name, 'kollichaitanya2024@gmail.com')].tenantId" --output tsv
$appId=az ad app create --display-name $appRegistrationName --query appId --output tsv
$objectId=az ad app show --id $appId --query id --output tsv
$clientSecretValue=az ad app credential reset --id $objectId --append --display-name $appRegistrationClientSecretName --end-date '2024-12-31' --query password --output tsv

[string]$subscriptionId=az account list --query "[?contains(user.name, 'kollichaitanya2024@gmail.com')].id" --output tsv

# [string]$serviceConnectionOjectid=az ad app list --query "[?contains(displayName, 'PythonProjects-service-connection')].id" --output tsv

[string]$scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"
az role assignment create --role "Key Vault Secrets User" --assignee-object-id $objectId --scope $scope   

az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientSecret" --value $clientSecretValue
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationTenantId" --value $tenantId
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientId" --value $appId

Write-Host "Client Secret is : ",$clientSecretValue
Write-Host "Tenant id is : ",$tenantId
Write-Host "Cliet id is : ",$appId



#az role assignment create --role "Key Vault Secrets User" --assignee-object-id 33a4fb2f-e88b-4252-9d14-6b2d76d555be --assignee-principal-type ServicePrincipal --scope $scope