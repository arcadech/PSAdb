<#
    .SYNOPSIS
        Connect to adb.

    .DESCRIPTION
        Connect to adb running at the given url, returns a connection object
        which can be used to run further queries agains adb.

    .PARAMETER Url
        Adb's URL

    .INPUTS
        None. You cannot pipe objects to Connect-Adb.

    .OUTPUTS
        Object Connect-Adb returns a connection object, containing the url and
        headers for further queries.

    .EXAMPLE
        C:\PS> $Connection = Connect-Adb -Url https://adb.arcade.ch
        C:\PS> $Connection

        Name                           Value
        ----                           -----
        Url                            https://adb.arcade.ch Headers
        {}

    .EXAMPLE
        C:\PS> $Credential = Get-Credential
        C:\PS> $Connection = Connect-Adb -Url https://adb.arcade.ch -Credential $Credential
        C:\PS> $Connection

        Name                           Value
        ----                           -----
        Url                            https://adb.arcade.ch Headers {x-auth-token}

    .LINK
        Disconnect-Adb
#>
function Connect-Adb
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Url,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]
        $Credential
    )

        if($Credential -eq $null){
            $Connection = @{
                Url = $Url
                Headers = @{}
            }
            $script:AdbConnection = $Connection
            return $Connection
        }
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
