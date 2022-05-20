<#
_author_ = Mesut Kaptanoglu <mesut_kaptanoglu@dell.com>
_twitter_ = @mkaptano
_version_ = 0.9
_Dev_Status_ = Test / Experimental
Copyright © 2022 Dell Inc. or its subsidiaries. All Rights Reserved.
No implied support and test in test environment/device before using in any production environment.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>

<#
.Synopsis
   This script is checking if a new Bios Update is available for your Dell device without the installation of any Dell tools. 
   It is leveraging BiosPC.xml catalog from downloads.dell.com/catalogs. This catalog is usually used for a Bios Feature to run an Bios Update from F12-Boot-Menu (Remote-Bios-Update). 
   IMPORTANT: Only commercial Dell Clients from 2020/2021 (like Dell Latitude xx10) or newer will support this feature. You may check if a "Remote Bios Update" feature is available in Boot-Menu. 
   
.DESCRIPTION
   This is an amended version of the original script for usage with Microsoft Endpoint Manager - Proactive Remediation. This File is for detection only. 
   
#>

#Identify current platform
$CurrentSysID = (Get-CimInstance -ClassName Win32_ComputerSystem).SystemSKUNumber

#Identify current Bios version
$CurrentBiosVer = Get-CimInstance Win32_Bios | select -ExpandProperty SMBIOSBIOSVersion

#Load & explore BiosPC.xml for next steps
[xml]$DataOnline = (New-Object System.Net.WebClient).DownloadString("https://downloads.dell.com/catalog/BiosPC.xml")
$Selection = $DataOnline.Manifest.SoftwareComponent | Where-Object {$_.SupportedSystems.Brand.Model.SystemID -eq $CurrentSysID}

#Check if system is supported
if ($Selection -eq $CurrentSysID){
echo "System is supported"
}
else {
echo "System is not supported"
exit 1
}

#Get Biosversion available
$NewBiosVersion = $DataOnline.Manifest.SoftwareComponent | Where-Object {$_.SupportedSystems.Brand.Model.SystemID -eq $CurrentSysID} | Select-Object -ExpandProperty dellversion

#Compare Bios versions
if ($NewBiosVersion -gt $CurrentBiosVer) {
   Write-Host "There is a new Bios update available! Your current Bios version is $CurrentBiosVer. New Bios version available is $NewBiosVersion"
	exit 1   
}

else {
    Write-Host "There is no Bios update available"
	exit 0
}