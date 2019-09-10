<#
    .SYNOPSIS
        Create a new adb resource.

    .DESCRIPTION
        This command will create a new adb resource.

    .INPUTS
        Adb resource.

    .EXAMPLE
        PS C:\> $item = Get-AdbItem -Name 'myitem'
        PS C:\> $item.name = 'myitem2'
        PS C:\> $item | New-AdbResource
        Get an item, update it's name and post it back to the adb as a new item.
#>
function New-AdbResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        # The adb session.
        [Parameter(Mandatory = $false)]
        [PSTypeName('Adb.Session')]
        [System.Object]
        $Session,

        # The resource object.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object[]]
        $Resource,

        # The resource type to query.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Item', 'Property', 'Template', 'User', 'TokenRequest')]
        [System.String]
        $Type
    )

    begin
    {
        $Session = Test-AdbSession -Session $Session

        if ($PSBoundParameters.ContainsKey('Type'))
        {
            switch ($Type)
            {
                'Item'         { $adbType = 'items' }
                'Property'     { $adbType = 'properties' }
                'Template'     { $adbType = 'templates' }
                'User'         { $adbType = 'users' }
                'TokenRequest' { $adbType = 'tokenrequests' }
            }
        }
    }

    process
    {
        foreach ($currentResource in $Resource)
        {
            if ($PSCmdlet.ShouldProcess($currentResource.Name, 'Create'))
            {
                Write-Verbose "New item $($currentResource.Name)"

                if ($PSBoundParameters.ContainsKey('Type'))
                {
                    $uri = '{0}/{1}' -f $Session.Uri, $adbType
                }
                else
                {
                    $uri = '{0}/{1}' -f $Session.Uri, $currentResource._type
                }

                $body = $currentResource | ConvertTo-Json

                $requestSplat = Get-AdbSessionRequestSplat -Session $Session -Method 'Post'
                Invoke-RestMethod @requestSplat -Uri $Uri -Body $body -ErrorAction Stop | Out-Null
            }
        }
    }
}
