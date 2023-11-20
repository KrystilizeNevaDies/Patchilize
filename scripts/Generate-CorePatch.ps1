$corePatch = "./core.patch"

$workspace = "./corepatch-workspace"

if (-not (Test-Path "dependencies/Assembly-CSharp.dll")) {
    Write-Output "Assembly-CSharp.dll does not exist. run `./scripts/Link-Dependencies.ps1` to create it."
    exit 1
}

Write-Output "Creating the core patch."

if (Test-Path $corePatch) {
    Remove-Item -Recurse -Force $corePatch | Out-Null
}

Write-Output "Hiding the patches directory."
New-Item -ItemType Directory -Force -Path "./patches-hidden" | Out-Null
foreach ($patch in Get-ChildItem "./patches" -Filter "*.patch" -Recurse) {
    Move-Item $patch "./patches-hidden" -Force
}

Write-Output "Creating the workspace without any patches."
./scripts/New-Workspace.ps1 $workspace
Write-Output "Workspace created."

Write-Output "Generating the core patch."

# build project
dotnet build $workspace/Assembly-CSharp.csproj --property WarningLevel=0

# diff the two dlls
$original = "./dependencies/Assembly-CSharp.dll"
$signature = "./dependencies/Assembly-CSharp.dll.sig"
$patched = "./patched.dll"

# save the core dll
New-Item -ItemType Directory -Force -Path "./patches" | Out-Null
Copy-Item "$workspace/bin/Debug/netstandard2.1/Assembly-CSharp.dll" $patched -Force

# restore patches from hidden directory
foreach ($patch in Get-ChildItem "./patches-hidden" -Filter "*.patch" -Recurse) {
    Move-Item $patch "./patches" -Force
}

./scripts/Diff.ps1 signature $original $signature
./scripts/Diff.ps1 delta $signature $patched $corePatch --progress
Remove-Item $signature
Remove-Item $patched
Remove-Item -Recurse -Force "./patches-hidden" | Out-Null
./scripts/Remove-Workspace.ps1 $workspace