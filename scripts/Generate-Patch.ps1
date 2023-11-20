$headPatch = "./head.patch"

if (-not (Test-Path $headPatch)) {
    Write-Output "Head patch does not exist: $corePatch run `./scripts/Generate-HeadPatch.ps1` to create it."
    exit 1
}

if (-not ($args.Length -eq 2)) {
    Write-Output "Usage: Generate-Patch.ps1 <workspace> <patchName>"
    exit 1
}

$workspace = $args[0]
$patchName = $args[1]

if (-not (Test-Path $workspace)) {
    Write-Output "Workspace does not exist: $workspace"
    exit 1
}

# build project
dotnet build $workspace/Assembly-CSharp.csproj --property WarningLevel=0

# construct fully patched dll
$original = "./dependencies/Assembly-CSharp.dll"
$originalSignature = "$original.sig"
$modified = "$workspace/bin/Debug/netstandard2.1/Assembly-CSharp.dll"

# diff between original and modified
# this is also called the absolute patch
Write-Output "Generating patch: $patchName"
$delta = "$patchName.delta"
./scripts/Diff.ps1 signature $original $originalSignature
./scripts/Diff.ps1 delta $originalSignature $modified $delta

# diff to the head patch
# this is the relative patch
$headPatchSignature = "$headPatch.sig"
$newPatch = "./patches/$(Get-Date -UFormat %s -Millisecond 0)_$patchName.patch"
./scripts/Diff.ps1 signature $headPatch $headPatchSignature
./scripts/Diff.ps1 delta $headPatchSignature $delta $newPatch
Write-Output "Patch generated: $newPatch"

# cleanup
Remove-Item $delta
Remove-Item $originalSignature
Remove-Item $headPatchSignature

# create new head patch
./scripts/Generate-HeadPatch.ps1