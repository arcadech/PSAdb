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
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param
    (
        # The adb session.
        [Parameter(Mandatory = $false)]
        [PSTypeName('Adb.Session')]
        $Session,

        # The resource type to query.
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Item', 'Property', 'Template', 'User', 'TokenRequest')]
        [System.String]
        $Type,

        # The resource name.
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Name')]
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
            if ($PSCmdlet.ParameterSetName -eq 'Name')
            {
                $uri = '{0}/{1}/{2}' -f $Session.Uri, $adbType, $currentName
            }
            else
            {
                $query = @()

                # Append all optional paramters as http query
                if ($PSBoundParameters.ContainsKey('Filter'))
                {
                    foreach ($filterKey in $Filter.Keys)
                    {
                        $query += '{0}={1}' -f $filterKey, $Filter[$filterKey]
                    }
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
