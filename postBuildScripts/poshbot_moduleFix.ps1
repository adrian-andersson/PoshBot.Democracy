#First get all the permissions required

try{
    import-module -name configuration -ErrorAction Stop
}catch{
    throw 'Configuration module not on this machine. Please install it first'
}

$content = get-content $scriptVars.moduleFile
 
#Search for permissions
$permissions = foreach($line in $content)
{
    if($line -like '*Permissions*=*')
    {
        $perm = $($($line -split '=')[1] -split ',')[0]
        $perm = $perm -replace "'",''
        $perm = $perm.trim()
        if($perm.length -gt 2){
            $perm
        }
        
    }
}
$permissions = $permissions | Select-object -unique
$permissionsMetaData = @()
foreach($permission in $permissions)
{
    $ht = @{}
    $ht.Name = $permission
    $ht.Description = $permission
    $permissionsMetaData += $ht
}

#The old btversion
#$metadata = import-metadata $scriptVars.manifestFile
$metadata = import-metadata $scriptVars.newManifestPath
$metadata.privatedata.permissions = $permissionsMetaData
#The new btversion
#$metadata|export-metadata -Path $scriptVars.manifestFile
$metadata|export-metadata -Path $scriptVars.newManifestPath
Test-ModuleManifest $scriptVars.newManifestPath