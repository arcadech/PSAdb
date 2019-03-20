
function Get-AdbItem {
    <#
    .SYNOPSIS

    get adb item(s)

    .DESCRIPTION

    alias for Get-AdbRessource -Type "items"

    #>
        param(
            [Parameter(ValueFromPipeline=$true)]
            [Object]$Connection,
            [String]$Name,
            [String]$FilterName,
            [String]$Query,
            [String]$Fields,
            [Int]$Limit = 10,
            [Int]$Skip,
            [Switch] $All
        )
        process {
            $Params = $PSBoundParameters
            $Params.Add("Type", "Items")
            Get-AdbRessource @Params
        }
    }
