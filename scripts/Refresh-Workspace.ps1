# Description: Refreshes the workspace by removing it and creating it again.

if (-not ($args.Length -eq 1)) {
    Write-Output "Usage: Refresh-Workspace.ps1 <workspace>"
    exit 1
}

./scripts/Remove-Workspace.ps1 $args[0]
./scripts/New-Workspace.ps1 $args[0]