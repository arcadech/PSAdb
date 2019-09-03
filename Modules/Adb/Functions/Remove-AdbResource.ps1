<#
    .SYNOPSIS
        Generic command to remove adb documents.

    .DESCRIPTION
        This command will remove adb documets specified by name and type or as
        ducument object.

    .INPUTS
        Adb document.

    .EXAMPLE
        PS C:\> Get-AdbItem -Name 'myitem' | Remove-AdbResource
        Remove the item 'myitem'.
#>
function Remove-AdbResource
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
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Resource')]
        [PSTypeName('Adb.Resource')]
        [System.Object[]]
        $Resource,

        # The resource type to query.
        [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
        [ValidateSet('Item', 'Property', 'Template', 'User', 'TokenRequest')]
        [System.String]
        $Type,

        # The resource name.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Name')]
        [System.String[]]
        $Name
    )

    begin
    {
        $Session = Test-AdbSession -Session $Session

        switch ($Type)
        {
            'Item'         { $adbType = 'items' }
            'Property'     { $adbType = 'properties' }
            'Template'     { $adbType = 'templates' }
            'User'         { $adbType = 'users' }
            'TokenRequest' { $adbType = 'tokenrequests' }
        }

        $removeList = [System.Collections.ArrayList]::new()
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'Name')
        {
            foreach ($currentName in $Name)
            {
                $removeList.Add(@{
                    Type = $adbType
                    Name = $currentName
                })
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'Resource')
        {
            foreach ($currentResource in $Resource)
            {
                $removeList.Add(@{
                    Type = $currentResource._type
                    Name = $currentResource.Name
                })
            }
        }
    }

    end
    {
        foreach ($removeItem in $removeList)
        {
            if ($PSCmdlet.ShouldProcess($removeItem.Name, 'Remove'))
            {
                try
                {
                    Write-Verbose "Remove item $($removeItem.Name)"

                    $uri = '{0}/{1}/{2}' -f $Session.Uri, $removeItem.Type, $removeItem.Name

                    $requestSplat = Get-AdbSessionRequestSplat -Session $Session -Method 'Delete'
                    Invoke-RestMethod @requestSplat -Uri $Uri -ErrorAction Stop | Out-Null
                }
                catch
                {
                    throw $_
                }
            }
        }
    }
}
