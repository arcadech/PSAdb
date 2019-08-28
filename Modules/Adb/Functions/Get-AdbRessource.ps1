function Get-AdbRessource {
    <#
    .SYNOPSIS

    get adb ressource

    .DESCRIPTION

    get single document or list of documents

    .PARAMETER Connection

    Connection Object received by Connect-Adb
    or by New-AdbConnection

    .PARAMETER Name

    Query for single document with given name

    .PARAMETER FilterName

    Filter document names (regex)

    .PARAMETER Query

    MongoDB Query (JSON-String)
    { properties: { hostname: "myserver123" } }

    .PARAMETER Fields

    MongoDB Fields (JSON-String)
    {name: 1, propertiesSources: 1}

    .PARAMETER Limit

    Limit number of results (default: 10)

    .PARAMETER Skip

    Number of items to skip

    .PARAMETER All

    Turn of limit

    .INPUTS

    Connection Object

    .OUTPUTS

    Documents(s)

    .EXAMPLE

    C:\PS> Get-AdbRessource -Type items -Name myserver123

    #>
        param(
            [Parameter(ValueFromPipeline=$true)]
            [Object]$Connection,
            [Parameter(Mandatory=$true)]
            [ValidateSet("items", "properties", "templates", "users")]
            [String]$Type,
            [String]$Name,
            [String]$FilterName,
            [String]$Query,
            [String]$Fields,
            [Int]$Limit = 10,
            [Int]$Skip,
            [Switch] $All
        )
        begin {
            if(-not ($PSBoundParameters.ContainsKey('Connection'))){
                $Connection = $script:AdbConnection
            }
        }
        process {
            if(-not ($Connection)){
                throw "No connection to adb"
            }
            if($PSBoundParameters.ContainsKey('Name')){
                $Uri = "$($Connection.Url)/api/v1/$($Type.toLower())/${Name}"
            } else {
                $Params = $PSBoundParameters
                $Params.Remove('Connection') | Out-Null
                if($All){
                    $Params.Remove('Limit') | Out-Null
                }
                $QueryString = Get-QueryString($Params)
                $Uri = "$($Connection.Url)/api/v1/$($Type.toLower())/$($QueryString.toLower())"
            }
            try {
                $Response = Invoke-RestMethod -Uri $Uri -Method "GET" -Headers $Connection.Headers
                $Result = $Response.data
                if($Result -is [System.Array]){
                    for($i=0; $i -lt $Result.length; $i++){
                        $Result[$i] | Add-Member Type $Type
                    }
                } else {
                    $Result | Add-Member Type $Type
                }
                $Result
            } catch {
                Write-Debug $_.Exception.Message
                $StatusCode = [int]$_.Exception.Response.StatusCode
                switch($StatusCode){
                    404 { Write-Debug "no documents found"; return }
                }
                throw $_.Exception
            }
        }
    }