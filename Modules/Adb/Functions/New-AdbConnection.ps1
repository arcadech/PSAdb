function New-AdbConnection {
    <#
    .SYNOPSIS

    create adb connection

    .DESCRIPTION

    manually create adb connection by
    providing a token and a username

    .PARAMETER Url

    adb's URL

    .PARAMETER Token

    auth token

    .INPUTS

    None. You cannot pipe objects to New-AdbConnection

    .OUTPUTS

    Object Create-AdbConnection returns a connection object,
    containing the url and headers for further queries.

    .EXAMPLE

    C:\PS> $Connection = New-AdbConnection -Url https://adb.arcade.ch
    C:\PS> $Connection

    Name                           Value
    ----                           -----
    Url                            https://adb.arcade.ch
    Headers                        {}

    .EXAMPLE

    C:\PS> $Connection = New-AdbConnection -Url https://adb.arcade.ch -Token zhyjwjlw3öjj13j13jj
    C:\PS> $Connection

    Name                           Value
    ----                           -----
    Url                            https://adb.arcade.ch
    Headers                        {x-auth-token}

    .LINK
    Connect-Adb

    #>
        param(
            [Parameter(Mandatory=$true)]
            [String]$Url,
            [Parameter(Mandatory=$true)]
            [String]$Token
        )
        $Connection = @{
            Url = $Url
            Headers = @{
                "x-auth-token" = $Token
            }
        }
        $script:AdbConnection = $Connection
        return $Connection
    }
