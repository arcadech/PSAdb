# Adb PowerShell Module

[![PowerShell Gallery - psadb](https://img.shields.io/badge/PowerShell_Gallery-psadb-0072C6.svg)](https://www.powershellgallery.com/packages/psadb)
[![GitHub - Release](https://img.shields.io/github/release/arcadesolutionsag/psadb.svg)](https://github.com/arcadesolutionsag/psadb/releases)
[![AppVeyor - master](https://img.shields.io/appveyor/ci/claudiospizzi/psadb/master.svg)](https://ci.appveyor.com/project/claudiospizzi/psadb/branch/master)
[![AppVeyor - dev](https://img.shields.io/appveyor/ci/claudiospizzi/psadb/dev.svg)](https://ci.appveyor.com/project/arcadesolutionsag/psadb/branch/dev)

## Introduction

This PowerShell Module is a wrapper for the ADB REST api.

## Features

### Functions

* New-AdbConnection: Create a connection object based on given url and token, can be used for subsequent queries. Connection object is returned and saved in the session.
* Connect-Adb: Create a connection object based on given url and credentials, can be used for subsequent queries. Connection object is returned and saved in the session.
* Disconnect-Adb: Logout from adb (either using the given connection or the one stored in the session)
* Get-AdbOwnUser: Query own user
* Get-AdbRessource: Query ADB ressources. Supported types: items, properties, templates, users
* Get-AdbItem: Alias for querying adb ressources of type items
* Remove-AdbRessource: Delete an adb ressource
* Save-AdbRessource: update or create adb ressource
* Test-AdbItemValidation: validate item for template, either by providing the item object or the item's name

### Examples

#### Connections

A connection can be either created by providing credentials or by passing a
token. Either way, a connection object is returned, while the connection is also
stored in the session. Guest connections without any authentication are also
supported.

```powershell
# Token-based connection
$connection = New-AdbConnection -Url 'https://adb.contoso.com' -Token 'XXX'

# Credential-based connection
$credential = Get-Credential
$connection = Connect-Adb -Url 'https://adb.contoso.com' -Credential $credential

# Using Adb as a guest, omitting the Credential parameter
New-AdbConnection -Url 'https://adb.contoso.com'
```



```
C:\PS> # Query own adb user
C:\PS>Get-AdbOwnUser

_id                      name   permissions ldapUser
---                      ----   ----------- --------
5bfe8a1e4e89e500150cd22d admrbi {admin}         True

C:\PS> # Query some adb ressources (templates in this case)
C:\PS> $Templates = Get-AdbRessource -Type "templates" -Limit 3
C:\PS> $Templates.Name
nextcloud
vmware-vm
sonde
C:\PS>
C:\PS> # Prepare a new item
C:\PS> $Item = @{
>>   name = "test_item"
>>   properties = @{
>>     hostname = "test"
>>     vc_username = "test"
>>   }
>> }
C:\PS> # Save new item to adb 
C:\PS> $Item | Save-AdbRessource -Type "items"
C:\PS>
C:\PS> # Query new item
C:\PS> $Item = Get-AdbItem -Name "test_item"
C:\PS> # this does the same
C:\PS> $Item = Get-AdbRessource -Name "test_item" -Type "items"
C:\PS> # checking that the item was actually saved to the db
C:\PS> $Item._id
5c797ecaa0e053000fe23f20
C:\PS>
C:\PS> # Prepare updated item
C:\PS> $Item.properties | Add-Member net_ipadress 10.1.2.3
C:\PS> $Item.properties.psobject.properties.remove("vc_username")
C:\PS> 
C:\PS> # Validate new item
C:\PS> $Item | Test-AdbItemValidation -Template "nextcloud" -Verbose
VERBOSE: Validation passed
C:\PS>
C:\PS> # Save updated item
C:\PS> $Item | Save-AdbRessource
C:\PS>
C:\PS> # Validate item again, but this time validate the document stored online
C:\PS> $Item | Test-AdbItemValidation -Name "test_item" -Template "nextcloud"
C:\PS>
C:\PS>
C:\PS> # Delete the item
C:\PS> $Item | Remove-AdbRessource
C:\PS> # or
C:\PS> Remove-AdbRessource -Name "test_item" -Type "items"
C:\PS>
C:\PS> # the Get-AdbRessource, Save-AdbRessource, Remove-AdbRessource
C:\PS> # can be used for items, properties, templates, users
```


## Versions

Please find all versions in the [GitHub Releases] section and the release notes
in the [CHANGELOG.md] file.

## Installation

Use the following command to install the module from the [PowerShell Gallery],
if the PackageManagement and PowerShellGet modules are available:

```powershell
# Download and install the module
Install-Module -Name 'psadb'
```

Alternatively, download the latest release from GitHub and install the module
manually on your local system:

1. Download the latest release from GitHub as a ZIP file: [GitHub Releases]
2. Extract the module and install it: [Installing a PowerShell Module]

## Requirements

The following minimum requirements are necessary to use this module, or in other
words are used to test this module:

* Windows PowerShell 5.1
* Windows Server 2012 R2

## Contribute

Please feel free to contribute by opening new issues or providing pull requests.
For the best development experience, open this project as a folder in Visual
Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code] with the [PowerShell Extension]
* [Pester], [PSScriptAnalyzer] and [psake] PowerShell Modules

[PowerShell Gallery]: https://www.powershellgallery.com/packages/SecurityFever
[GitHub Releases]: https://github.com/claudiospizzi/SecurityFever/releases
[Installing a PowerShell Module]: https://msdn.microsoft.com/en-us/library/dd878350

[CHANGELOG.md]: CHANGELOG.md

[Visual Studio Code]: https://code.visualstudio.com/
[PowerShell Extension]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell
[Pester]: https://www.powershellgallery.com/packages/Pester
[PSScriptAnalyzer]: https://www.powershellgallery.com/packages/PSScriptAnalyzer
[psake]: https://www.powershellgallery.com/packages/psake









