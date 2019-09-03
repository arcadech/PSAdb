<#
    .SYNOPSIS
        Get an item from the adb.

    .DESCRIPTION
        Reutrn a custom object with the adb user and token information.
#>
function Get-AdbItem
{
    [CmdletBinding()]
    param
    (
        # The adb session.
        [Parameter(Mandatory = $false)]
        [PSTypeName('Adb.Session')]
        [System.Object]
        $Session,

        # The resource name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # Specify how the items are sort.
        [Parameter(Mandatory = $false)]
        [System.String]
        $Filter,

        # Specify how the items are sort.
        [Parameter(Mandatory = $false)]
        [System.String]
        $Sort,

        # Specified the fields to return.
        [Parameter(Mandatory = $false)]
        [System.String[]]
        $Field,

        # Option to limit the number of return objects.
        [Parameter(Mandatory = $false)]
        [System.Int32]
        $Limit,

        # Option to skip the specified number of first objects.
        [Parameter(Mandatory = $false)]
        [System.Int32]
        $Skip
    )

    Get-AdbResource -Type 'Item' @PSBoundParameters
}
