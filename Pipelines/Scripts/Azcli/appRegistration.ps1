param(
    [string]$appRegistrationName,
    [string]$appRegistrationClientSecretName,
    [string]$keyVaultName,
    [string]$resourceGroupName
)
[string]$tenantId="a576b579-5332-4070-ac30-3f4d5a911ac0"
[string]$appId=az ad app create --display-name $appRegistrationName --query appId --output tsv
[string]$objectId=az ad app show --id $appId --query id --output tsv
[string]$appRegServicePrincipleObjectId=az ad sp create --id $appId --query id --output tsv
Write-Host "appRegServicePrincipleObjectId is : $appRegServicePrincipleObjectId"
Write-Host "App service and service principle created successfully"
[string]$clientSecretValue=az ad app credential reset --id $objectId --append --display-name $appRegistrationClientSecretName --end-date '2024-12-31' --query password --output tsv

#[string]$subscriptionId=az account list --query "[?contains(user.name, 'kollichaitanya2024@gmail.com')].id" --output tsv
[string]$subscriptionId="2dc383a6-eed6-4aa2-a955-b4fffa7da912"
Write-Host "Subbscription id is : $subscriptionId"
[string]$scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"
Write-Host "Scope is : $scope"
az role assignment create --role "Key Vault Secrets User" --assignee-object-id $appRegServicePrincipleObjectId --scope $scope --assignee-principal-type ServicePrincipal

az keyvault secret list --vault-name $keyVaultName
Write-Host "AppRegistrationClientSecret is : $clientSecretValue" 
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientSecret" --value $clientSecretValue
Write-Host "AppRegistrationClientSecret Updated"
Write-Host "AppRegistrationTenantId is : $tenantId" 
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationTenantId" --value $tenantId
Write-Host "AppRegistrationTenantId Updated"
Write-Host "AppRegistrationClientId is : $appId" 
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientId" --value $appId
Write-Host "AppRegistrationClientId Updated"

Write-Host "Key Vault values updated"