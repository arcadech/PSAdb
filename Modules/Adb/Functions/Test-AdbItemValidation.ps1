
function Test-AdbItemValidation {
    <#
    .SYNOPSIS

    test item validation

    .DESCRIPTION

    test item validation, either
    by providing the item to test or
    the name of an item which is stored
    in adb

    .PARAMETER Connection

    Connection Object received by Connect-Adb
    or by New-AdbConnection

    .PARAMETER Name

    Name of the item to validate

    .PARAMETER Template

    Name of the template to use
    for validation

    .PARAMETER Document

    Document to validate
    .INPUTS

    Document Object

    .OUTPUTS

    Nothing (or Error if invalid)

    .EXAMPLE

    C:\PS> $Item | Test-AdbItemValidation -Template "windows_vm"

    .EXAMPLE

    C:\PS> Test-AdbItemValidation -Template "windows_vm" -Item $Item

    .EXAMPLE

    C:\PS> Test-AdbItemValidation -Template "windows_vm" -Name "myserver123"

    #>
        param(
            [Object]$Connection,
            [Parameter(Mandatory=$true)]
            [String]$Template,
            [Parameter(Mandatory=$true, ParameterSetName="ByItem", ValueFromPipeline=$true)]
            [Object]$Item,
            [Parameter(Mandatory=$true, ParameterSetName="ByName")]
            [String]$Name
        )
        begin {
            if(-not ($PSBoundParameters.ContainsKey('Connection'))){
                $Connection = $script:AdbConnection
            }
            if(-not ($Connection)){
                throw "No connection to adb, plese run 'Connect-Adb'"
            }
        }
        process {
            if($Document){
                $Uri = "$($Connection.Url)/api/v1/templates/${Template}/validate"
                $Method = "POST"
            } else {
                $Uri = "$($Connection.Url)/api/v1/templates/${Template}/validate/${Name}"
                $Method = "GET"
            }
            Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Connection.Headers | Out-Null
            Write-Verbose "Validation passed"
        }
    }