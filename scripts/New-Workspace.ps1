Write-Output "Setting up sources using native code plus any preexisting patches."

$workspaceDir = "workspace"
if ($args.Length -gt 0) {
    $workspaceDir = $args[0]
}

# if head patch exists, initialize using it
$headPatch = "./head.patch"
$original = "./dependencies/Assembly-CSharp.dll"
$patched = "./patching/Assembly-CSharp.dll"

New-Item -ItemType Directory -Force -Path "./patching" | Out-Null

if (Test-Path "core.patch") {
    if (-not (Test-Path $headPatch)) {
        Write-Output "Head patch does not exist: $corePatch run `./scripts/Generate-HeadPatch.ps1` to create it."
        exit 1
    }
    
    ./scripts/Diff.ps1 patch $original $headPatch $patched
} else {
    # otherwise, initialize using the original dll
    Copy-Item $original $patched -Force
}

# create a directory for the source code
New-Item -ItemType Directory -Force -Path $workspaceDir | Out-Null

# decompile IL
# we need to move into the directory for the dependencies to correctly resolve
$currentLocation = Get-Location
Set-Location $workspaceDir
ilspycmd -o "." -p --nested-directories -r "../dependencies" "../$patched"
Set-Location $currentLocation

# link project
dotnet sln Patchilize.sln add $workspaceDir/Assembly-CSharp.csproj

# the assembly info file is not needed
Remove-Item $workspaceDir/Properties/AssemblyInfo.cs

# cleanup
Remove-Item -Recurse -Force "./patching" | Out-Null
