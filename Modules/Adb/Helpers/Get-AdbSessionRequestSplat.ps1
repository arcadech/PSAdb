<#
    .SYNOPSIS
        Get the request splat for a http request.
#>
function Get-AdbSessionRequestSplat
{
    [CmdletBinding()]
    param
    (
        # The adb session to test.
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [PSTypeName('Adb.Session')]
        [System.Object]
        $Session,

        # The http method to use.
        [Parameter(Mandatory = $true)]
        [ValidateSet('Get', 'Post', 'Put', 'Delete')]
        [System.String]
        $Method
    )

    # Create the request splat, by default only the accept header
    $requestSplat = @{
        Method  = $Method
        Headers = @{
            'Accept' = 'application/json'
        }
    }

    # Set the content type if we have a body
    if ($Method -in 'Post', 'Put')
    {
        $requestSplat['ContentType'] = 'application/json'
    }

    # Add the authentication token, if we don't use guest authentication
    if (-not [System.String]::IsNullOrEmpty($Session.Token))
    {
        $requestSplat['Headers']['X-Auth-Token'] = $Session.Token
    }

    return $requestSplat
}
