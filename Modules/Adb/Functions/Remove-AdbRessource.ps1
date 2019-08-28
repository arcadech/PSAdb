
function Remove-AdbRessource {
    <#
    .SYNOPSIS

    remove adb ressource

    .DESCRIPTION

    remove single document

    .PARAMETER Connection

    Connection Object received by Connect-Adb
    or by New-AdbConnection

    .PARAMETER Name

    Name of the document to remove

    .PARAMETER Type

    Type of the document

    .PARAMETER Document

    Document to remove
    .INPUTS

    Document Object

    .OUTPUTS

    Nothing

    .EXAMPLE

    C:\PS> $Item | Remove-AdbRessource

    .EXAMPLE

    C:\PS> Remove-AdbRessource -Document $item

    .EXAMPLE

    C:\PS> Remove-AdbRessource -Name myserver123

    #>
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
        param(
            [Object]$Connection,
            [Parameter(Mandatory=$true, ParameterSetName="ByName")]
            [String]$Name,
            [Parameter(Mandatory=$true, ParameterSetName="ByName")]
            [ValidateSet("items", "properties", "templates", "users")]
            [String]$Type,
            [Parameter(Mandatory=$true, ParameterSetName="ByDocument", ValueFromPipeline=$true)]
            [Object]$Document
        )
        begin {
            if(-not ($PSBoundParameters.ContainsKey('Connection'))){
                $Connection = $script:AdbConnection
            }
            if(-not ($Connection)){
                throw "No connection to adb"
            }
        }
        process {
            if($PSBoundParameters.ContainsKey('Document')){
                $Name = $Document.Name
                $Type = $Document.Type
            }
            if ($PSCmdlet.ShouldProcess($Name, 'Remove Document.')) {
                $Uri = "$($Connection.Url)/api/v1/$($Type)/${Name}"
                Invoke-RestMethod -Uri $Uri -Method "DELETE" -Headers $Connection.Headers | Out-Null
            }
        }
    }