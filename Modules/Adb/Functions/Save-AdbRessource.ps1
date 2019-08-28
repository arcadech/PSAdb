function Save-AdbRessource {
    <#
    .SYNOPSIS

    save adb ressource

    .DESCRIPTION

    update or create single document

    .PARAMETER Connection

    Connection Object received by Connect-Adb
    or by New-AdbConnection

    .PARAMETER OriginalName

    Name of the document when renaming

    .PARAMETER Type

    Type of the document

    .PARAMETER Document

    Document to update
    .INPUTS

    Document Object

    .OUTPUTS

    Nothing

    .EXAMPLE

    C:\PS> $Item = Get-AdbRessource -Type items -Name myserver123
    C:\PS> $Item.Properties.hostname = server123
    C:\PS> $Item | Save-AdbRessource

    .EXAMPLE

    C:\PS> $Item = Get-AdbRessource -Type items -Name myserver123
    C:\PS> $Item.Properties.hostname = server123
    C:\PS> Save-AdbRessource -Document $Item

    .EXAMPLE

    C:\PS> $Item = Get-AdbRessource -Type items -Name myserver123
    C:\PS> $Item.Name = myserver12345
    C:\PS> $Item | Save-AdbRessource -OriginalName myserver123

    #>
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
        param(
            [Object]$Connection,
            [String]$OriginalName,
            [String]$Type,
            [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
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
            $Name = $Document.Name
            if($PSBoundParameters.ContainsKey('OriginalName')){
                $Name = $OriginalName
            }
            if ($PSCmdlet.ShouldProcess($Name, 'Save Document.')) {
                if(-not($Type)){
                    $Type = $Document.Type
                }
                $Uri = "$($Connection.Url)/api/v1/${Type}/${Name}?upsert=1&patch=0"
                Invoke-RestMethod -Uri $Uri -Method "PUT" -Body ( $Document | ConvertTo-Json) -Headers $Connection.Headers -ContentType "application/json" | Out-Null
            }
        }
    }