resource weatherappstgacc2 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'weatherappstgaccbicep1'
  tags: {
    displayName: 'weatherappstgaccbicep1'
  }
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_GRS'
    tier: 'Standard'
  }
}
