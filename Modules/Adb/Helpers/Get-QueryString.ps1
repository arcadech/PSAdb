<#
    .SYNOPSIS
        Get query string for an adb request.

    .DESCRIPTION
        Helper function to generate a query string based on the provided
        hashtable.

    .PARAMETER Params
        Hashtable containing the parameters based on which to build the query
        string.

    .INPUTS
        Hashtable containing the params.

    .OUTPUTS
        System.String. Get-QueryString returns a string containing the query
        string.

    .EXAMPLE
        PS C:\> Get-QueryString @{limit = 10, skip = 5}
        ?limit=10&skip=5
#>
function Get-QueryString
{
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [HashTable]$Params
    )

    process
    {
        $QueryString = ""
        foreach ($Param in $Params.GetEnumerator())
        {
            if ($null -ne $Param.Value)
            {
                if ($QueryString.length -gt 0)
                {
                    $QueryString += "&"
                }
                else
                {
                    $QueryString += "?"
                }
                $QueryString += "$($Param.Name)=$($Param.Value)"
            }
        }
        return $QueryString
    }
}
