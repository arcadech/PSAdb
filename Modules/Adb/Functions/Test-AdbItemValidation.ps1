<#
    .SYNOPSIS
        Test an item against a template schema.

    .DESCRIPTION
        This command will invoke the built-in validation to test the specified
        item against the template.

    .INPUTS
        Item names.

    .EXAMPLE
        PS C:\> Test-AdbValidation -Template 'mytemplate' -Name 'myitem'
        Test the item 'myitem' against the template 'mytemplate'.
#>
function Test-AdbItemValidation
{
    [CmdletBinding()]
    param
    (
        # The adb session.
        [Parameter(Mandatory = $false)]
        [PSTypeName('Adb.Session')]
        [System.Object]
        $Session,

        # The name of the template to test against.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Template,

        # Item name to validate.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String[]]
        $Name
    )

    begin
    {
        $Session = Test-AdbSession -Session $Session
    }

    process
    {
        foreach ($currentName in $Name)
        {
            try
            {
                Write-Verbose "Test item $currentName against $Template"

                $uri = '{0}/templates/{1}/validate/{2}' -f $Session.Uri, $Template, $currentName

                $requestSplat = Get-AdbSessionRequestSplat -Session $Session -Method 'Get'
                $result = Invoke-RestMethod @requestSplat -Uri $Uri -ErrorAction Stop

                Write-Output $result
            }
            catch
            {
                throw $_
            }
        }
    }
}
