<#
    .SYNOPSIS
        Get the current adb user.

    .DESCRIPTION
        Reutrn a custom object with the adb user and token information.
#>
function Get-AdbUser
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

    $user = Get-AdbResource -Session $Session -Type 'User' -Name 'me'

    if ($null -ne $user)
    {
        [PSCustomObject] @{
            PSTypeName = 'Adb.User'
            User       = $user.name
            Role       = $user.permissions
        }
    }
    else
    {
        throw 'User not found!'
    }
}
