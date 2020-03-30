<#
    .SYNOPSIS
        Return the adb session, if connected.

    .DESCRIPTION
        This command will verify if a connection to the adb server is available.
        If yes, the session will be returned. If not, nothing is returned.
#>
function Get-AdbSession
{
    [CmdletBinding()]
    param ()

    if ($null -ne $Script:AdbSession)
    {
        Write-Output $Script:AdbSession
    }
}
