<#
    .SYNOPSIS
        Get an item from the adb.

    .DESCRIPTION
        Reutrn a custom object with the adb user and token information.
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
