
$vmName = 'vmDK111'
$resourceGroup = 'RG-Laxmi'
$adminCredential = Get-Credential

#New AzVM -ResourceGroupName $resourceGroup -Name $vmName -credential $adminCredential -Image Ubuntu2204

$azVmParams = @{
    ResourceGroupName = $resourceGroup
    Name              = $vmName
    Credential        = $adminCredential
    Image             = 'Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest'
    OpenPorts         = 22
}
New-AzVm @azVmParams