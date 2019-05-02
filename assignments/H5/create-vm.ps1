New-VM -Name "TestVM" -MemoryStartupBytes 1GB -Generation 1 -NewVHDPath "C:\TestVMDisk.vhdx" -NewVHDSizeBytes 5GB -SwitchName "eth1"
Add-VMSCSIController -VMName "TestVM"
Add-VMDVDDrive -VMName "TestVM" -ControllerNumber 1 -ControllerLocation 1 -Path "C:\archlinux-2019.04.01-x86_64.iso"
Start-VM -Name "TestVM"
