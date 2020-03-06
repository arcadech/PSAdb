<#
    .SYNOPSIS
        Test if the adb session is valid.

    .DESCRIPTION
        This cmdlet will verify if the adb session specified as parameter is
        valid. If the session is not specified or is null, the fallback to the
        session stored in the module context is performed. If any session is
        valid, it will be returned. If not, a execption will throw.
#>
function Test-AdbSession
{
    [CmdletBinding()]
    param
    (
        # The adb session to test.
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [PSTypeName('Adb.Session')]
        [System.Object]
        $Session
    )

    if ($null -ne $Session)
    {
        return $Session
    }
    elseif ($null -ne $Script:AdbSession)
    {
        return $Script:AdbSession
    }
    else
    {
        throw 'No valid adb session found!'
    }
}
