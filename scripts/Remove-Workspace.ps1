$workspaceDir = "workspace"
if ($args.Length -eq 1) {
    $workspaceDir = $args[0]
} else {
    if ($args.Length -gt 1) {
        Write-Output "Usage: Remove-Workspace.ps1 <workspace>"
        exit 1
    }
}

if (-not (Test-Path "$workspaceDir/Assembly-CSharp.csproj")) {
    Write-Output "Workspace does not exist: $workspaceDir"
    exit 1
}

Write-Output "Removing workspace."

if (Test-Path $workspaceDir) {
    Remove-Item -Recurse -Force $workspaceDir | Out-Null
}
dotnet sln Patchilize.sln remove $workspaceDir\Assembly-CSharp.csproj