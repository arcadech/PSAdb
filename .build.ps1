
# Import build tasks
. InvokeBuildHelperTasks

# Build configuration
$IBHConfig.RepositoryTask.Token = Use-VaultSecureString -TargetName 'GitHub Token (arcadesolutionsag)'
$IBHConfig.GalleryTask.Token    = Use-VaultSecureString -TargetName 'PowerShell Gallery Key (arcadesolutionsag)'
