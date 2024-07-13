param(
    [string]$appRegistrationName,
    [string]$appRegistrationClientSecretName,
    [string]$keyVaultName,
    [string]$resourceGroupName
)
$tenantId=az account list --query "[?contains(user.name, 'kollichaitanya2024@gmail.com')].tenantId" --output tsv
$appId=az ad app create --display-name $appRegistrationName --query appId --output tsv
$objectId=az ad app show --id $appId --query id --output tsv
$appRegServicePrincipleObjectId=az ad sp create --id $appId --query id --output tsv
Write-Host "appRegServicePrincipleObjectId is : $appRegServicePrincipleObjectId"
Write-Host "App service and service principle created successfully"
$clientSecretValue=az ad app credential reset --id $objectId --append --display-name $appRegistrationClientSecretName --end-date '2024-12-31' --query password --output tsv

#[string]$subscriptionId=az account list --query "[?contains(user.name, 'kollichaitanya2024@gmail.com')].id" --output tsv
[string]$subscriptionId="2dc383a6-eed6-4aa2-a955-b4fffa7da912"
Write-Host "Subbscription id is : $subscriptionId"
[string]$scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"
Write-Host "Scope is : $scope"
az role assignment create --role "Key Vault Secrets User" --assignee-object-id $appRegServicePrincipleObjectId --scope $scope --assignee-principal-type ServicePrincipal

az keyvault secret list --vault-name $keyVaultName
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientSecret" --value $clientSecretValue
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationTenantId" --value $tenantId
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientId" --value $appId

Write-Host "Key Vault values updated"