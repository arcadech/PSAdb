function Get-QueryString {
<#
.SYNOPSIS

get query string

.DESCRIPTION

Helper function to generate a query string
based on the provided hashtable.

.PARAMETER Params

Hashtable containing the parameters based
on which to build the query string.

.INPUTS

Hashtable containing the params

.OUTPUTS

System.String. Get-QueryString returns a string containing
the query string.

.EXAMPLE

C:\PS> Get-QueryString @{limit = 10, skip = 5}
?limit=10&skip=5

#>
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [HashTable]$Params
    )
    process {
        $QueryString = ""
        foreach ($Param in $Params.GetEnumerator()){
            if ($null -ne $Param.Value){
                if($QueryString.length -gt 0){
                    $QueryString += "&"
                } else {
                    $QueryString += "?"
                }
                $QueryString += "$($Param.Name)=$($Param.Value)"
            }
        }
        return $QueryString
    }
}

function Connect-Adb {
<#
.SYNOPSIS

connect to adb

.DESCRIPTION

Connect to adb running at the given url,
returns a connection object which can be
used to run further queries agains adb.

.PARAMETER Url

adb's URL

.INPUTS

None. You cannot pipe objects to Connect-Adb

.OUTPUTS

Object Connect-Adb returns a connection object,
containing the url and headers for further queries.

.EXAMPLE

C:\PS> $Connection = Connect-Adb -Url https://adb.arcade.ch
C:\PS> $Connection

Name                           Value
----                           -----
Url                            https://adb.arcade.ch
Headers                        {}

.EXAMPLE

C:\PS> $Credential = Get-Credential
C:\PS> $Connection = Connect-Adb -Url https://adb.arcade.ch -Credential $Credential
C:\PS> $Connection

Name                           Value
----                           -----
Url                            https://adb.arcade.ch
Headers                        {x-auth-token}

.LINK
Disconnect-Adb

#>
    param(
        [Parameter(Mandatory=$true)]
        [String]$Url,
        [System.Management.Automation.PSCredential]$Credential
    )
    if($Credential -eq $null){
        $Connection = @{
            Url = $Url
            Headers = @{}
        }
        $script:AdbConnection = $Connection
        return $Connection
    }
    process {
        $Uri = "${Url}/api/v1/users/login"
        $Body = @{
            name = $Credential.UserName
            password = $Credential.GetNetworkCredential().Password
        }
        try{
            $Response = Invoke-RestMethod -Uri $Uri -Method "POST" -Body $Body
            $Connection = New-AdbConnection -Url $Url -Token $Response.data.token.token
            $script:AdbConnection = $Connection
            return $Connection
        } catch {
            throw $_.Exception
        }
    }
}


function Disconnect-Adb {
<#
.SYNOPSIS

logout of adb

.DESCRIPTION

Lougout of adb, deleting auth token.

.PARAMETER Connection

Connection Object received by Connect-Adb

.INPUTS

Connection Object

.OUTPUTS

None

.EXAMPLE

C:\PS> Disconnect-Adb -Connection $Connection

.EXAMPLE

C:\PS> $Connection | Disconnect-Adb

.LINK
Connect-Adb

#>
    param(
        [Parameter(ValueFromPipeline=$true)]
        [Object]$Connection
    )
    begin {
        if(-not ($PSBoundParameters.ContainsKey('Connection'))){
            $Connection = $script:AdbConnection
        }
    }
    process {
        if(-not ($Connection)){
            throw "No connection to adb"
        }
        $Uri = "$($Connection.Url)/api/v1/users/me/token"
        Invoke-RestMethod -Uri $Uri -Method "DELETE" -Headers $Connection.Headers | Out-Null
    }
}

function Get-AdbOwnUser {
<#
.SYNOPSIS

get own user

.DESCRIPTION

Get own user based on connection

.PARAMETER Connection

Connection Object received by Connect-Adb

.INPUTS

Connection Object

.OUTPUTS

own user

.EXAMPLE

C:\PS> Get-AdbOwnUser -Connection $Connection

.EXAMPLE

C:\PS> $Connection | Get-AdbOwnUser

.LINK
Connect-Adb

#>
    param(
        [Parameter(ValueFromPipeline=$true)]
        [Object]$Connection
    )
    begin {
        if(-not ($PSBoundParameters.ContainsKey('Connection'))){
            $Connection = $script:AdbConnection
        }
    }
    process {
        if(-not ($Connection)){
            throw "No connection to adb"
        }
        $Uri = "$($Connection.Url)/api/v1/users/me"
        $user = $null
        try{
            $Response = Invoke-RestMethod -Uri $Uri -Method "GET" -Headers $Connection.Headers
            $user = $Response.data
        } catch{
            Write-Debug $_.Exception.Message
        }
        finally{
            $user
        }
    }
}

function Get-AdbRessource {
<#
.SYNOPSIS

get adb ressource

.DESCRIPTION

get single document or list of documents

.PARAMETER Connection

Connection Object received by Connect-Adb
or by New-AdbConnection

.PARAMETER Name

Query for single document with given name

.PARAMETER FilterName

Filter document names (regex)

.PARAMETER Query

MongoDB Query (JSON-String)
{ properties: { hostname: "myserver123" } }

.PARAMETER Fields

MongoDB Fields (JSON-String)
{name: 1, propertiesSources: 1}

.PARAMETER Limit

Limit number of results (default: 10)

.PARAMETER Skip

Number of items to skip

.PARAMETER All

Turn of limit

.INPUTS

Connection Object

.OUTPUTS

Documents(s)

.EXAMPLE

C:\PS> Get-AdbRessource -Type items -Name myserver123

#>
    param(
        [Parameter(ValueFromPipeline=$true)]
        [Object]$Connection,
        [Parameter(Mandatory=$true)]
        [ValidateSet("items", "properties", "templates", "users")]
        [String]$Type,
        [String]$Name,
        [String]$FilterName,
        [String]$Query,
        [String]$Fields,
        [Int]$Limit = 10,
        [Int]$Skip,
        [Switch] $All
    )
    begin {
        if(-not ($PSBoundParameters.ContainsKey('Connection'))){
            $Connection = $script:AdbConnection
        }
    }
    process {
        if(-not ($Connection)){
            throw "No connection to adb"
        }
        if($PSBoundParameters.ContainsKey('Name')){
            $Uri = "$($Connection.Url)/api/v1/$($Type.toLower())/${Name}"
        } else {
            $Params = $PSBoundParameters
            $Params.Remove('Connection') | Out-Null
            if($All){
                $Params.Remove('Limit') | Out-Null
            }
            $QueryString = Get-QueryString($Params)
            $Uri = "$($Connection.Url)/api/v1/$($Type.toLower())/$($QueryString.toLower())"
        }
        try {
            $Response = Invoke-RestMethod -Uri $Uri -Method "GET" -Headers $Connection.Headers
            $Result = $Response.data
            if($Result -is [System.Array]){
                for($i=0; $i -lt $Result.length; $i++){
                    $Result[$i] | Add-Member Type $Type
                }
            } else {
                $Result | Add-Member Type $Type
            }
            $Result
        } catch {
            Write-Debug $_.Exception.Message
            $StatusCode = [int]$_.Exception.Response.StatusCode
            switch($StatusCode){
                404 { Write-Debug "no documents found"; return }
            }
            throw $_.Exception
        }
    }
}

function Save-AdbRessource {
<#
.SYNOPSIS

save adb ressource

.DESCRIPTION

update or create single document

.PARAMETER Connection

Connection Object received by Connect-Adb
or by New-AdbConnection

.PARAMETER OriginalName

Name of the document when renaming

.PARAMETER Type

Type of the document

.PARAMETER Document

Document to update
.INPUTS

Document Object

.OUTPUTS

Nothing

.EXAMPLE

C:\PS> $Item = Get-AdbRessource -Type items -Name myserver123
C:\PS> $Item.Properties.hostname = server123
C:\PS> $Item | Save-AdbRessource

.EXAMPLE

C:\PS> $Item = Get-AdbRessource -Type items -Name myserver123
C:\PS> $Item.Properties.hostname = server123
C:\PS> Save-AdbRessource -Document $Item

.EXAMPLE

C:\PS> $Item = Get-AdbRessource -Type items -Name myserver123
C:\PS> $Item.Name = myserver12345
C:\PS> $Item | Save-AdbRessource -OriginalName myserver123

#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Object]$Connection,
        [String]$OriginalName,
        [String]$Type,
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        [Object]$Document
    )
    begin {
        if(-not ($PSBoundParameters.ContainsKey('Connection'))){
            $Connection = $script:AdbConnection
        }
        if(-not ($Connection)){
            throw "No connection to adb"
        }
    }
    process {
        $Name = $Document.Name
        if($PSBoundParameters.ContainsKey('OriginalName')){
            $Name = $OriginalName
        }
        if ($PSCmdlet.ShouldProcess($Name, 'Save Document.')) {
            if(-not($Type)){
                $Type = $Document.Type
            }
            $Uri = "$($Connection.Url)/api/v1/${Type}/${Name}?upsert=1&patch=0"
            Invoke-RestMethod -Uri $Uri -Method "PUT" -Body ( $Document | ConvertTo-Json) -Headers $Connection.Headers -ContentType "application/json" | Out-Null
        }
    }
}

function Remove-AdbRessource {
<#
.SYNOPSIS

remove adb ressource

.DESCRIPTION

remove single document

.PARAMETER Connection

Connection Object received by Connect-Adb
or by New-AdbConnection

.PARAMETER Name

Name of the document to remove

.PARAMETER Type

Type of the document

.PARAMETER Document

Document to remove
.INPUTS

Document Object

.OUTPUTS

Nothing

.EXAMPLE

C:\PS> $Item | Remove-AdbRessource

.EXAMPLE

C:\PS> Remove-AdbRessource -Document $item

.EXAMPLE

C:\PS> Remove-AdbRessource -Name myserver123

#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Object]$Connection,
        [Parameter(Mandatory=$true, ParameterSetName="ByName")]
        [String]$Name,
        [Parameter(Mandatory=$true, ParameterSetName="ByName")]
        [ValidateSet("items", "properties", "templates", "users")]
        [String]$Type,
        [Parameter(Mandatory=$true, ParameterSetName="ByDocument", ValueFromPipeline=$true)]
        [Object]$Document
    )
    begin {
        if(-not ($PSBoundParameters.ContainsKey('Connection'))){
            $Connection = $script:AdbConnection
        }
        if(-not ($Connection)){
            throw "No connection to adb"
        }
    }
    process {
        if($PSBoundParameters.ContainsKey('Document')){
            $Name = $Document.Name
            $Type = $Document.Type
        }
        if ($PSCmdlet.ShouldProcess($Name, 'Remove Document.')) {
            $Uri = "$($Connection.Url)/api/v1/$($Type)/${Name}"
            Invoke-RestMethod -Uri $Uri -Method "DELETE" -Headers $Connection.Headers | Out-Null
        }
    }
}

function Test-AdbItemValidation {
<#
.SYNOPSIS

test item validation

.DESCRIPTION

test item validation, either
by providing the item to test or
the name of an item which is stored
in adb

.PARAMETER Connection

Connection Object received by Connect-Adb
or by New-AdbConnection

.PARAMETER Name

Name of the item to validate

.PARAMETER Template

Name of the template to use
for validation

.PARAMETER Document

Document to validate
.INPUTS

Document Object

.OUTPUTS

Nothing (or Error if invalid)

.EXAMPLE

C:\PS> $Item | Test-AdbItemValidation -Template "windows_vm"

.EXAMPLE

C:\PS> Test-AdbItemValidation -Template "windows_vm" -Item $Item

.EXAMPLE

C:\PS> Test-AdbItemValidation -Template "windows_vm" -Name "myserver123"

#>
    param(
        [Object]$Connection,
        [Parameter(Mandatory=$true)]
        [String]$Template,
        [Parameter(Mandatory=$true, ParameterSetName="ByItem", ValueFromPipeline=$true)]
        [Object]$Item,
        [Parameter(Mandatory=$true, ParameterSetName="ByName")]
        [String]$Name
    )
    begin {
        if(-not ($PSBoundParameters.ContainsKey('Connection'))){
            $Connection = $script:AdbConnection
        }
        if(-not ($Connection)){
            throw "No connection to adb, plese run 'Connect-Adb'"
        }
    }
    process {
        if($Document){
            $Uri = "$($Connection.Url)/api/v1/templates/${Template}/validate"
            $Method = "POST"
        } else {
            $Uri = "$($Connection.Url)/api/v1/templates/${Template}/validate/${Name}"
            $Method = "GET"
        }
        Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Connection.Headers | Out-Null
        Write-Verbose "Validation passed"
    }
}

function Get-AdbItem {
<#
.SYNOPSIS

get adb item(s)

.DESCRIPTION

alias for Get-AdbRessource -Type "items"

#>
    param(
        [Parameter(ValueFromPipeline=$true)]
        [Object]$Connection,
        [String]$Name,
        [String]$FilterName,
        [String]$Query,
        [String]$Fields,
        [Int]$Limit = 10,
        [Int]$Skip,
        [Switch] $All
    )
    process {
        $Params = $PSBoundParameters
        $Params.Add("Type", "Items")
        Get-AdbRessource @Params
    }
}
