
if (-not ($args.Length -eq 1)) {
    Write-Output "Usage: Generate-InitPatches.ps1 <numberOfPatches>"
    exit 1
}

# check if there are any patches
$patches = Get-ChildItem "./patches" -Filter "*.patch" -Recurse
if (-not ($patches.Length -eq 0)) {
    Write-Output "Patch files found, cannot generate initial patches if there are already patches."
    exit 1
}

./scripts/Generate-CorePatch.ps1
./scripts/Generate-HeadPatch.ps1

# create a temp workspace
$workspace = "init-patches"
./scripts/New-Workspace.ps1 $workspace

# generate initial patches
$numberOfPatches = $args[0]

for ($i = 0; $i -lt $numberOfPatches; $i++) {
    $patchName = "init"
    ./scripts/Generate-Patch.ps1 $workspace $patchName
}

# cleanup
./scripts/Remove-Workspace.ps1 $workspace