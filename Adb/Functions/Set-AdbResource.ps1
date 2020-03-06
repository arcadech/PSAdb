<#
    .SYNOPSIS
        Update an existing adb resource.

    .DESCRIPTION
        This command will put the specified adb resource and update it if it
        already exists.

    .INPUTS
        Adb document.

    .EXAMPLE
        PS C:\> $item = Get-AdbItem -Name 'myitem'
        PS C:\> $item.properties.hostname = 'newhostname'
        PS C:\> $item | Set-AdbResource
        Get an item, update it's hostname and put it back to the adb.
#>
function Set-AdbResource
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
        [PSTypeName('Adb.Resource')]
        [System.Object[]]
        $Resource
    )

    begin
    {
        $Session = Test-AdbSession -Session $Session
    }

    process
    {
        foreach ($currentResource in $Resource)
        {
            if ($PSCmdlet.ShouldProcess($currentResource.Name, 'Update'))
            {
                Write-Verbose "Set item $($currentResource.Name)"

                $uri = '{0}/{1}/{2}?upsert=0&patch=0' -f $Session.Uri, $currentResource._type, $currentResource.Name

                # Define a new object only with the required propreties
                $newResource = [PSCustomObject] @{
                    name          = $currentResource.name
                    templateName  = $currentResource.templateName
                    properties    = $currentResource.properties
                    childrenNames = $currentResource.childrenNames
                    parentsNames  = $currentResource.parentsNames
                    decryptFor    = $currentResource.decryptFor
                }

                $body = $newResource | ConvertTo-Json

                $requestSplat = Get-AdbSessionRequestSplat -Session $Session -Method 'Put'
                Invoke-RestMethod @requestSplat -Uri $Uri -Body $body -ErrorAction Stop | Out-Null
            }
        }
    }
}
