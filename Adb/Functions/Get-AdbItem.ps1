<#
    .SYNOPSIS
        Get an item from the adb.

    .DESCRIPTION
        Return a custom object with the adb user and token information.

    .EXAMPLE
        PS C:\> Get-AdbItem -Name 'g_mygroup'
        Get the adb item with the name g_mygroup.

    .EXAMPLE
        PS C:\> Get-AdbItem -Filter @{ 'GitHub Autopilot' = '/^g_my/' }
        Get all the adb items with the name starting with g_my.
#>
function Get-AdbItem
{
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param
    (
        # The adb session.
        [Parameter(Mandatory = $false)]
        [PSTypeName('Adb.Session')]
        $Session,

        # The resource name.
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Name')]
        [System.String[]]
        $Name,

        # Specify how the items are sort.
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [System.Collections.Hashtable]
        $Filter,

        # Specify how the items are sort.
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [System.String[]]
        $Sort,

        # Specified the fields to return.
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [System.String[]]
        $Field,

        # Option to limit the number of return objects.
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [System.Int32]
        $Limit,

        # Option to skip the specified number of first objects.
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [System.Int32]
        $Skip
    )

    Get-AdbResource -Type 'Item' @PSBoundParameters
}
