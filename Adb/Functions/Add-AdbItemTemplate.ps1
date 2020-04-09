<#
    .SYNOPSIS
        Add the template name to a the adb item.

    .DESCRIPTION
        This command will query all existing templates on the adb item, merge
        them with the spcified template name and then update the new template
        list.

    .INPUTS
        None

    .OUTPUTS
        None

    .EXAMPLE
        PS C:\> Add-AdmItemTemplate -Name 'myname' -Template 'mytpl'
        Add the template mytpl to the item myname.
#>
function Add-AdbItemTemplate
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

        # The template to add to the item.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Template
    )

    $Session = Test-AdbSession -Session $Session

    $item = Get-AdbItem -Session $Session -Name $Name

    # Prepare the template list
    $templates = [System.String[]] $item.templatesNames
    $templates += $Template
    $templates = $templates | Select-Object -Unique | Sort-Object

    $item = [PSCustomObject] @{
        name           = $Name
        templatesNames = $templates
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
