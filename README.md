[![PowerShell Gallery - Adb](https://img.shields.io/badge/PowerShell_Gallery-Adb-0072C6.svg)](https://www.powershellgallery.com/packages/Adb)
[![GitHub - Release](https://img.shields.io/github/release/arcadesolutionsag/PSAdb.svg)](https://github.com/arcadesolutionsag/PSAdb/releases)
[![AppVeyor - master](https://img.shields.io/appveyor/ci/claudiospizzi/PSAdb/master.svg)](https://ci.appveyor.com/project/claudiospizzi/PSAdb/branch/master)

# Adb PowerShell Module

## Introduction

This PowerShell Module is a wrapper for the ADB REST api.

## Features

### Functions

* **Connect-AdbServer**  
  Login to the adb server. The session is stored in the module context and is
  returned as a session object if required.

* **Disconnect-AdbServer**  
  Logout from the adb server. Clear the session in the module context.

* **Get-AdbResource**  
  Generic command to get an adb documents.

* **Set-AdbResource**  
  Update an existing adb resource.

* **New-AdbResource**  
  Create a new adb resource.

* **Remove-AdbResource**  
  Generic command to remove adb documents.

* **Get-AdbUser**  
  Get the current adb user.

* **Get-AdbItem**  
  Get an item from the adb.

* **Test-AdbItemValidation**  
  Test an item against a template schema.

### Examples

A session can be created by providing credentials, passing a token or requesting
access from an active user. By omitting any login information and using the
`-Guest` parameter, access is limited to guest information.

```powershell
# Connect to the adb server by using username and password
Connect-AdbServer -Uri 'https://adb.contoso.com' -Credential 'john'

# Connect to the adb server by using an existing token
Connect-AdbServer -Uri 'https://adb.contoso.com' -Token 'XXX'

# Request access from the user john
Connect-AdbServer -Uri 'https://adb.contoso.com' -UserRequest 'john'

# Access the adb as a guest user
Connect-AdbServer -Uri 'https://adb.contoso.com' -Guest

# Store the adb session in a variable
$adbSession = Connect-AdbServer -Uri 'https://adb.contoso.com' -Credential 'john' -PassThru

# Get the current adb session
$adbSession = Get-AdbSession

# Logoff from the session stored in the module context
Disconnect-AdbServer

# Logoff from the specified session.
Disconnect-AdbServer -Session $adbSession
```

Get the current logged in adb user.

```powershell
# Query own adb user
Get-AdbUser
```

Query some adb resources, e.g. templates, items.

```powershell
# Query 3 templates
$templates = Get-AdbResource -Type 'Template' -Limit 3
$templates.Name

# Query new item
$item = Get-AdbItem -Name 'myitem'

# this does the same
$item = Get-AdbResource -Type 'Item' -Name 'myitem'
```

Save a new item to the adb.

```powershell
# Prepare a new item
$item = @{
    name       = 'test_item'
    properties = @{
        hostname    = 'test'
        vc_username = 'test'
    }
}

# Save new item to adb
$item | New-AdbResource -Type 'Item'
```

Update an item in the adb.

```powershell
$item = Get-AdbItem -Name 'myitem'

# Prepare updated item (add/remove properties)
$item.properties | Add-Member 'net_ipadress' '10.1.2.3'
$item.properties.PSObject.properties.Remove("vc_username")

# Save the updated item
$item | Set-AdbResource
```

Validate an item against a role schema:

```powershell
Test-AdbItemValidation -Template 'mytemplate' -Name 'myitem'
```

## Versions

Please find all versions in the [GitHub Releases] section and the release notes
in the [CHANGELOG.md] file.

## Installation

Use the following command to install the module from the [PowerShell Gallery],
if the PackageManagement and PowerShellGet modules are available:

```powershell
# Download and install the module
Install-Module -Name 'PSAdb'
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
