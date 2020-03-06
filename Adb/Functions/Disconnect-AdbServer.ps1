<#
    .SYNOPSIS
        Logout from the adb server. Clear the session in the module context.

    .DESCRIPTION
        Invoke the adb rest method /api/v1/users/me/token to kill the token in
        the adb and clear the session in the module state.

    .EXAMPLE
        PS C:\> Disconnect-AdbServer
        Disconnect the adb session stored in the module context.

    .EXAMPLE
        PS C:\> Disconnect-AdbServer -Session $adbSession
        Disconnect the specified adb session.

#>
function Disconnect-AdbServer
{
    [CmdletBinding()]
    param
    (
        # The adb session.
        [Parameter(Mandatory = $false)]
        [PSTypeName('Adb.Session')]
        [System.Object]
        $Session
    )

    $Session = Test-AdbSession -Session $Session

    try
    {
        # Invoke the /users/me/token resource to logout
        Get-AdbResource -Session $Session -Type 'User' -Name 'me/token' | Out-Null
    }
    catch
    {
        Write-Warning "Error during logoff: $_"
    }
    finally
    {
        if (-not $PSBoundParameters.ContainsKey('Session'))
        {
            $Script:AdbSession = $null
        }
    }
}
