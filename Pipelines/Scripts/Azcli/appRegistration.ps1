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

if(az ad app list --display-name $appRegistrationName --output tsv){
    [string]$appId=az ad app list --display-name $appRegistrationName --query "[].appId" --output tsv
}
else {
    [string]$appId=az ad app create --display-name $appRegistrationName --query appId --output tsv
}
[string]$objectId=az ad app show --id $appId --query id --output tsv
if (az ad sp list --display-name $appRegistrationName --output tsv) {
    [string]$appRegServicePrincipleObjectId=az ad sp list --display-name $appRegistrationName --query "[].id" --output tsv
}
else {
    [string]$appRegServicePrincipleObjectId=az ad sp create --id $appId --query id --output tsv
}
Write-Host "App service and service principle created successfully"
[string]$clientSecretValue=az ad app credential reset --id $objectId --append --display-name $appRegistrationClientSecretName --end-date '2024-12-31' --query password --output tsv

az keyvault set-policy --name $keyVaultName --object-id $appRegServicePrincipleObjectId --secret-permissions get, list

az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientSecret" --value $clientSecretValue
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationTenantId" --value $tenantId
az keyvault secret set --vault-name $keyVaultName --name "AppRegistrationClientId" --value $appId
az keyvault secret set --vault-name $keyVaultName --name "DataBaseName" --value $dbName
az keyvault secret set --vault-name $keyVaultName --name "DataBasePassword" --value $dbPassword
az keyvault secret set --vault-name $keyVaultName --name "DataBaseServerLink" --value $dbServerLink
az keyvault secret set --vault-name $keyVaultName --name "DataBaseUserName" --value $dbUserName
az keyvault secret set --vault-name $keyVaultName --name "PAT-Powershell" --value $patPowershell
Write-Host "Key Vault values updated"