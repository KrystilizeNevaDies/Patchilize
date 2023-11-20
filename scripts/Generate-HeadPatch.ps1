$corePatch = "./core.patch"

if (-not (Test-Path $corePatch)) {
    Write-Output "Core patch does not exist. run `./scripts/Generate-CorePatch.ps1` to create it."
    exit 1
}

$headPatch = "./head.patch"
$headPatchSwap = "./head.patch.swap"
Copy-Item $corePatch $headPatch -Force

$patches = Get-ChildItem "./patches" -Filter "*.patch" -Recurse | Sort-Object -Property Name
foreach ($patch in $patches) {
    Write-Output "Applying patch: $patch"
    ./scripts/Diff.ps1 patch $headPatch "./patches/$patch" $headPatchSwap
    Remove-Item $headPatch
    Rename-Item $headPatchSwap $headPatch
}

Write-Output "Head patch generated."