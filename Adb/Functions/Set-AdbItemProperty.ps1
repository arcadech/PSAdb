<#
    .SYNOPSIS
        Update a property on an adb item.

    .DESCRIPTION
        This command will put the value into the specified property if the item
        identified by the name.

    .INPUTS
        None

    .OUTPUTS
        None

    .EXAMPLE
        PS C:\> Set-AdbItemProperty -Name 'myname' -Property 'myprop' -Value 'myvalue'
        Update the item myname property myprop to the value myvalue.
#>
function Set-AdbItemProperty
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
        $Property,

        # The desired value of the property.
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Value
    )

    $Session = Test-AdbSession -Session $Session

    $item = [PSCustomObject] @{
        name       = $Name
        properties = [PSCustomObject] @{
            $Property = $Value
        }
    }

    $requestSplat = Get-AdbSessionRequestSplat -Session $Session -Method 'Put'
    $requestSplat['Uri'] = '{0}/items/{1}' -f $Session.Uri, $Name
    $requestSplat['Body'] = $item | ConvertTo-Json -Compress -Depth 99

    if ($PSCmdlet.ShouldProcess($requestSplat.Uri, $requestSplat.Method.ToUpper()))
    {
        Write-Verbose ('{0} {1}   {2}' -f $requestSplat.Method.ToUpper(), $requestSplat.Uri, $requestSplat.Body)
        Invoke-RestMethod @requestSplat -Verbose:$false -ErrorAction 'Stop' | Out-Null
    }
}
