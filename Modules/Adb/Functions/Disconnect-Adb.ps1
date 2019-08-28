
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
