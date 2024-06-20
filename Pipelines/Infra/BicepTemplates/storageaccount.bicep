param storageAccountName string = 'weatherappaccdefbicep'
param skuName string = 'Standard_GRS'
param skuTier string = 'Standard'


resource weatherappstgacc2 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  tags: {
    displayName: storageAccountName
  }
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: skuName
    tier: skuTier
  }
}
