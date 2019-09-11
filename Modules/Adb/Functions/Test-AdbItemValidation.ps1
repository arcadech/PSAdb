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
        $Name,

        # If specified, no result object is returned. If the item is valid,
        # nothing is returned. If the item is invalid, a error is thrown.
        [Parameter(Mandatory = $false)]
        [switch]
        $Quiet
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
                Invoke-RestMethod @requestSplat -Uri $Uri -ErrorAction Stop | Out-Null

                $result = [PSCustomObject] @{
                    Result     = $true
                    Message    = ''
                    Violations = @()
                }
            }
            catch
            {
                $errorMessage = $_.ErrorDetails.Message | ConvertFrom-Json | Select-Object -ExpandProperty 'error'

                if ([System.String]::IsNullOrEmpty($errorMessage))
                {
                    $errorMessage = $_.ErrorDetails.Message
                }


                $result = [PSCustomObject] @{
                    Result     = $false
                    Message    = $errorMessage
                    Violations = $errorMessage.Split(([System.String[]] ', '), [System.StringSplitOptions]::None)
                }
            }

            if ($Quiet.IsPresent)
            {
                if (-not $result.Result)
                {
                    throw $result.Message
                }
            }
            else
            {
                Write-Output $result
            }
        }
    }
}
