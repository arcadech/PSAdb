<#
    .SYNOPSIS
        Generic command to get an adb documents.

    .DESCRIPTION
        Get a single document or list of documents from the adb. It the Name
        parameter is specified, a single document is returned or an error if it
        was not found.

    .INPUTS
        Resource name.

    .OUTPUTS
        Adb documents.

    .EXAMPLE
        PS C:\> Get-AdbResource -Type 'Item' -Name 'myserver'
        Get the item myserver from the adb.
#>
function Get-AdbResource
{
    [CmdletBinding()]
    param
    (
        # The adb session.
        [Parameter(Mandatory = $false)]
        [PSTypeName('Adb.Session')]
        [System.Object]
        $Session,

        # The resource type to query.
        [Parameter(Mandatory = $true)]
        [ValidateSet('Item', 'Property', 'Template', 'User', 'TokenRequest')]
        [System.String]
        $Type,

        # The resource name.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String[]]
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
    }

    process
    {
        foreach ($currentName in $Name)
        {
            if ($PSBoundParameters.ContainsKey('Name'))
            {
                $uri = '{0}/{1}/{2}' -f $Session.Uri, $adbType, $Name
            }
            else
            {
                $query = @()

                # Append all optional paramters as http query
                if ($PSBoundParameters.ContainsKey('Filter'))
                {
                    $query += 'filter={0}' -f $Filter
                }
                if ($PSBoundParameters.ContainsKey('Sort'))
                {
                    $query += 'sort={0}' -f ($Sort -join ',')
                }
                if ($PSBoundParameters.ContainsKey('Field'))
                {
                    $query += 'fields={0}' -f ($Field -join ',')
                }
                if ($PSBoundParameters.ContainsKey('Limit'))
                {
                    $query += 'limit={0}' -f $Limit
                }
                if ($PSBoundParameters.ContainsKey('Skip'))
                {
                    $query += 'skip={0}' -f $Skip
                }

                $uri = '{0}/{1}/?{2}' -f $Session.Uri, $adbType, ($query -join '&')
            }

            try
            {
                Write-Verbose "Invoke query $Uri"

                $requestSplat = Get-AdbSessionRequestSplat -Session $Session -Method 'Get'
                $response = Invoke-RestMethod @requestSplat -Uri $Uri -ErrorAction Stop

                foreach ($item in $response.data)
                {
                    $item | Add-Member -MemberType 'NoteProperty' -Name '_type' -Value $adbType
                    $item.PSOBject.TypeNames.Insert(0, "Adb.Resource.$Type")
                    $item.PSOBject.TypeNames.Insert(0, "Adb.Resource")
                    Write-Output $item
                }
            }
            catch
            {
                throw $_
            }
        }
    }
}
