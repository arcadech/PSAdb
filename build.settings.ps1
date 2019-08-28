
Properties {

    $ModuleNames    = 'Adb'
    $ModuleMerge    = $false

    $GalleryEnabled = $true
    $GalleryKey     = Use-VaultSecureString -TargetName 'PowerShell Gallery Key'

    $GitHubEnabled  = $true
    $GitHubRepoName = 'arcadesolutionsag/PSAdb'
    $GitHubToken    = Use-VaultSecureString -TargetName 'GitHub Token'
}
