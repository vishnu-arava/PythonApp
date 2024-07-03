param(
    [string]$rgGroup,
    [string]$vmName
)

$publicIp=az vm show -d -g $rgGroup -n $vmName --query "publicIps" -o tsv
Write-Host "##vso[task.setvariable variable=varPublicIp;]$publicIp"
Write-Host "PublicIP is : $varpublicIP"