<#
    .SYNOPSIS
        Login to the adb server. The session is stored in the module context and
        is returned as a session object if required.

    .DESCRIPTION
        The adb server is specified by the uri. The uri may only contain the
        host and the protocoll. Path to the api must not be specified. Multiple
        autenticiation mechanism are supported:
        - Token
          This function will verify the token and then create a session from the
          given token.
        - Credential
          Authentication against the endpoint /api/v1/users/login is performed,
          the resulted token is stored in the session.
        - UserRequest
          Request access from a user by interactively query for the access in
          the user session. Specify the username in this parameter.
        - Guest
          No authentication at all, access is limited to guest information.

    .EXAMPLE
        PS C:\> Connect-AdbServer -Uri 'https://adb.contoso.com' -Credential 'john'
        Connect to the adb server by using username and password.

    .EXAMPLE
        PS C:\> Connect-AdbServer -Uri 'https://adb.contoso.com' -Token 'XXX'
        Connect to the adb server by using an existing token copied from the adb
        website.

    .EXAMPLE
        PS C:\> Connect-AdbServer -Uri 'https://adb.contoso.com' -UserRequest 'john'
        Request access from the user john.

    .EXAMPLE
        PS C:\> Connect-AdbServer -Uri 'https://adb.contoso.com' -Guest
        Access the adb as a guest user.

    .EXAMPLE
        PS C:\> $adbSession = Connect-AdbServer -Uri 'https://adb.contoso.com' -Credential 'john' -PassThru
        Store the adb session in a separate variable.
#>
function Connect-AdbServer
{
    [CmdletBinding()]
    param
    (
        # Adb uri.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        # Adb credentials.
        [Parameter(Mandatory = $true, ParameterSetName = 'Credential')]
        [System.Management.Automation.PSCredential]
        $Credential,

        # Adb token.
        [Parameter(Mandatory = $true, ParameterSetName = 'Token')]
        [System.String]
        $Token,

        # Adb token.
        [Parameter(Mandatory = $true, ParameterSetName = 'UserRequest')]
        [System.String]
        $UserRequest,

        # Use adb as guest.
        [Parameter(Mandatory = $true, ParameterSetName = 'Guest')]
        [switch]
        $Guest,

        # Return the session object.
        [Parameter(Mandatory = $false)]
        [switch]
        $PassThru
    )

    # Prepare a session object
    $session = [PSCustomObject] @{
        PSTypeName = 'Adb.Session'
        Type       = $PSCmdlet.ParameterSetName
        Uri        = '{0}/api/v1' -f $Uri.TrimEnd('/')
        Token      = ''
    }

    switch ($session.Type)
    {
        'Credential'
        {
            try
            {
                # Login to the adb by using username and password
                $loginSplat = @{
                    Method      = 'Post'
                    Uri         = '{0}/users/login' -f $session.Uri
                    Body        = [PSCustomObject] @{ name = $Credential.UserName; password = $Credential.GetNetworkCredential().Password } | ConvertTo-Json -Compress
                    ContentType = 'application/json'
                    Headers     = @{ 'Accept' = 'application/json' }
                }
                $result = Invoke-RestMethod @loginSplat -ErrorAction 'Stop'

                # Store the requested token
                $session.Token = $result.data.token.token
            }
            catch
            {
                throw "Credential-based login on $Uri failed: $_"
            }
        }

        'Token'
        {
            try
            {
                # Store the passed token
                $session.Token = $Token

                # Verify the passed token by quering the current user
                Get-AdbResource -Session $session -Type 'User' -Name 'me' | Out-Null
            }
            catch
            {
                throw "The spcified token for $Uri is not valid: $_"
            }
        }

        'UserRequest'
        {
            try
            {
                # Request a login token from the specified user
                $result = Get-AdbResource -Session $session -Type 'TokenRequest' -Name $UserRequest

                # Store the requested token
                $session.Token = $result.data.token.token
            }
            catch
            {
                throw "Token request failed for $Uri with user $UserRequest`: $_"
            }
        }

        'Guest'
        {
            try
            {
                # Just try the request with the empty token to get the guest user
                Get-AdbResource -Session $session -Type 'User' -Name 'me' | Out-Null
            }
            catch
            {
                throw "Guest access to $Uri is not possible: $_"
            }
        }
    }

    # Store the session in the module context
    $Script:AdbSession = $session

    if ($PassThru.IsPresent)
    {
        $Script:AdbSession
    }
}
