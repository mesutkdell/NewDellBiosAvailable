# NewDellBiosAvailable
Is a new Dell Bios available for my device?

**NOTE:** This is an experimental script that should be used for testing only. 

This script is checking if a new Bios Update is available for your Dell device without the installation of any Dell tools like Dell Command Update or Dell SupportAssist. 

It is leveraging a file called BiosPC.xml. This file is usually used for a Bios Feature to run an Bios Update from F12-Boot-Menu (Remote-Bios-Update). Please see the "The basics / background" section of this repository for more details. 

The XML-File called BiosPC.xml can be found on https://downloads.dell.com/catalogs. Currently I cannot say something about the update cadence nor can I confirm that all updates offered in the catalog are the latest ones. There might be a difference to dell.com or other tools/catalogs like Dell Command Update, Dell SupportAssist or the 3rd Party Software Catalog that is leveraged by Microsoft Endpoint Manager Configuration Manager. 

The aim of this experimental show-case is to see if there is a use-case for organizations that do not want to use any of the solutions available and are looking for an alternative. 

**IMPORTANT:** 
Only commercial Dell Clients from 2020/2021 (like Dell Latitude xx10) or newer will support this feature. 
You may check if a "Remote Bios Update" feature is available in Boot-Menu to make sure which platforms of your PC-fleet is supported or not. 

## The basics / background
As mentioned this script leverages an XML-File that is used by Dell BiosConnect Firmware Update capability of newer Dell devices. 
By starting an device and accessing the F12 Boot menu, these devices offer a "Bios Flash Update - Remote" feature. The device than connects to the Dell Backend systems in the Internet and looks if an new Bios Update is available. If an Bios update is available you can initiate the update process. The following short video is demonstrating this feature.

https://user-images.githubusercontent.com/88332918/169333160-fe3b923e-a444-4f3d-9832-2ad4e8c49150.mp4

By using the BiosPC.xml of this solution I thought it could be an alternative solution for those that don't want to use any OEM Tools and other update mechanisms. There maybe some limitations, but given that some organizations newer update their bios or are not actively monitoring these kind of updates, this might be an approach they could leverage and modify for their unique usecase. 

## The script
The script is build for usage with Microsoft Endpoint Manager Proactive Remediations. I will only provide an detection script in this repository. 

The script looks like this: 

```
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

#Get Biosversion available
$NewBiosVersion = $DataOnline.Manifest.SoftwareComponent | Where-Object {$_.SupportedSystems.Brand.Model.SystemID -eq $CurrentSysID} | Select-Object -ExpandProperty dellversion

#Check if system is supported by BiosPC.xml
if ($NewBiosVersion -eq $null) {
Write-Host "System is not supported by this script!"
exit
}

#Compare Bios versions
if ([version]$NewBiosVersion -le [version]$CurrentBiosVer) {
   Write-Host "There is no new Bios update available! Your current Bios version is $CurrentBiosVer. Bios version available is $NewBiosVersion."
	exit 0   
}

else {
    Write-Host "There is a new Bios update available! Your current Bios version is $CurrentBiosVer. New Bios version available is $NewBiosVersion"
	exit 1
}
```

### Screenshots
System not supported: 

![notsupported](https://user-images.githubusercontent.com/88332918/169347892-29692dde-2247-4a8a-b196-94169cac08f4.JPG)

Bios update not available (System is up-to-date): 

![Capture_7750_nobios](https://user-images.githubusercontent.com/88332918/169347997-34aff26d-db57-4f43-b13a-1f4f8423ff19.png)

Bios update is available: 

![Capture_7320detach_newbiosavl](https://user-images.githubusercontent.com/88332918/169348226-fe8c2d53-c2af-4bce-984c-0f34b032d8a9.PNG)



