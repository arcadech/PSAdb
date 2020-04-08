<#
    .SYNOPSIS
        Remove a property from an adb item.

    .DESCRIPTION
        This command will remove the property from the item identified by the
        name.

    .INPUTS
        None

    .OUTPUTS
        None

    .EXAMPLE
        PS C:\>Remove-AdbItemProperty -Name 'myname' -Property 'myprop'
        Remove proeprty myprop from item myname.
#>
function Remove-AdbItemProperty
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        # The adb session.
        [Parameter(Mandatory = $false)]
        [PSTypeName('Adb.Session')]
        [System.Object]
        $Session,

        # The item name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # The item property name to update.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Property
    )

    $Session = Test-AdbSession -Session $Session

    $requestSplat = Get-AdbSessionRequestSplat -Session $Session -Method 'Delete'
    $requestSplat['Uri'] = '{0}/items/{1}/properties/{2}' -f $Session.Uri, $Name, $Property

    if ($PSCmdlet.ShouldProcess($requestSplat.Uri, $requestSplat.Method.ToUpper()))
    {
        Write-Verbose ('{0} {1}' -f $requestSplat.Method.ToUpper(), $requestSplat.Uri)
        Invoke-RestMethod @requestSplat -Verbose:$false -ErrorAction 'Stop' | Out-Null
    }
}
