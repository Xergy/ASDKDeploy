
#enter Azure Stack VM Name Instance number
$VMInstance = "01"
#enter Azure Stack VM Name. Example azurestack
$vmname = "ASH$($VMInstance)"
#enter cloudbuilder.vhd path. F:VMsazurestackcloudbuilder.vhdx
$cloudbuilder = "D:\ASDK\AzureStackDevelopmentKit\CloudBuilder.vhdx"
#enter vmpath for VHD files. Example f:vmsazurestack note: do not add the trailing to the end.
$vmpath = 'D:\VMs'
#enter memory. exmample 75
[int64]$mem = 225
$vmmem = 1gb*$mem

$ProcCount = 28

#create NAT switch for VM
$natswitch = Get-VMSwitch -Name "NATSwitch" -ErrorAction SilentlyContinue

if($natswitch -eq $null) {
    New-VMSwitch -Name "NATSwitch" -SwitchType Internal -Verbose

    $NIC = Get-NetAdapter  | where Name -like "vEthernet*(NATSwitch)"

    New-NetIPAddress -IPAddress 172.16.0.1 -PrefixLength 24 -InterfaceIndex $NIC.ifIndex

    New-NetNat -Name "NatSwitch" -InternalIPInterfaceAddressPrefix "172.16.0.0/24" -Verbose

    $natswitch = Get-VMSwitch -Name "NATSwitch" -ErrorAction SilentlyContinue
}

#create new azure stack as generation 2 VM

$vm = New-VM -Name $vmname -MemoryStartupBytes $vmmem -SwitchName $natswitch.name -Generation 2 -Path $vmpath

#give VM 12 processors and specify the automatic stop action and set static memory
set-vm -VM $vm -ProcessorCount $ProcCount -AutomaticStopAction ShutDown -StaticMemory

#expose Processor enabling nested virtualization
set-vmprocessor -vmname $vm.name -ExposeVirtualizationExtensions $true -Verbose

#enable MAC address spoofing
get-vmnetworkadapter -VMName $vm.name | set-vmnetworkadapter -MacAddressSpoofing on

#disable time synchronization
Disable-VMIntegrationService -Name 'time synchronization' -VM $vm

#Create Virtual Hards Folder
$VMDiskPath = "$($VMPath)\$($vmname)\Virtual Hard Disks"
New-Item $VMDiskPath -ItemType directory -Force

$OSDisk = Get-Item $cloudbuilder 

$OSDisk = $OSDisk | Move-Item -Destination $VMDiskPath -PassThru
#$OSDisk | fl *

Add-VMHardDiskDrive -VMName $vm.name -Path $OSDisk.FullName

#resize Cloudbuilder.vhdx to 200gb
Resize-VHD -Path $OSDisk.FullName -SizeBytes 350gb

#create VHDX drives for S2D cluster in Azure Stack

$DiskCount = 1..4
foreach ($disk in $DiskCount)
{
 $vhd = New-VHD -Path "$($VMDiskPath)\$($vmname)-Disk$($disk).vhdx" -Dynamic -SizeBytes 2tb
 Add-VMHardDiskDrive -VMName $vm.name -Path $vhd.path
}
