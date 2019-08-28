
ADB Powershell Module
======================

ADB REST API Powershell Module Wrapper

# Commands
* New-AdbConnection: Create a connection object based on given url and token, can be used for subsequent queries. Connection object is returned and saved in the session.
* Connect-Adb: Create a connection object based on given url and credentials, can be used for subsequent queries. Connection object is returned and saved in the session.
* Disconnect-Adb: Logout from adb (either using the given connection or the one stored in the session)
* Get-AdbOwnUser: Query own user
* Get-AdbRessource: Query ADB ressources. Supported types: items, properties, templates, users
* Get-AdbItem: Alias for querying adb ressources of type items
* Remove-AdbRessource: Delete an adb ressource
* Save-AdbRessource: update or create adb ressource
* Test-AdbItemValidation: validate item for template, either by providing the item object or the item's name

# Usage examples
```powershell
C:\PS> # A connection can be either created by providing credentials or by passing a token
C:\PS> # either way, a connection object is returned, while the connection is also stored in the session (current ps window)
C:\PS> # A)
C:\PS> $Connection = New-AdbConnection -Url "https://adb.arcade.ch" -Token "XXXXXXXXX"
C:\PS> # or B)
C:\PS> $Credential = Get-Credential
C:\PS> $Connection = Connect-Adb -Url "https://adb.arcade.ch" -Credential $Credential
C:\PS> $Connection

Name                           Value
----                           -----
Url                            https://adb.arcade.ch
Headers                        {x-auth-token}

C:\PS> # To login as guest, just omit the Credential parameter
C:\PS> New-AdbConnection -Url https://adb.arcade.ch

Name                           Value
----                           -----
Url                            https://adb.arcade.ch
Headers                        {}

C:\PS>
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

# License
MIT

# Author
arcade solutions ag - Raphael Bicker <raphael.bicker@arcade.ch>
