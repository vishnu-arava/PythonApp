param(
    [string]$resourceGroup 
)
$adminCredential = Get-Credential -Message 'Enter a username and password for the VM administrator.'


#list of vms
$vms='web','app'

foreach($vm in $vms){
     Write-Host "vmname is $vm"
    $vmname = "cnferencedemo-$vm"
    Write-Output "creating vm :$vmname"

    $azVmParams = @{
        ResourceGroupName = $resourceGroup
        Name = $vmname
        Credential = $adminCredential
        Image = 'Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest'
        OpenPorts = 22
        Location = 'eastus2'    
    }
    New-AzVm @azVmParams
}