Write-Output "Linking Dependencies for Open Company"

$lethalCompanyPath = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 1966720").InstallLocation
if ($null -eq $lethalCompanyPath) {
    throw "Steam Lethal Company install not found"
}

$cd = Get-Location
$unprocessedPath = Join-Path $cd "unprocessed"
$processedPath = Join-Path $cd "dependencies"

New-Item -ItemType Directory -Force -Path $unprocessedPath
New-Item -ItemType Directory -Force -Path $processedPath

# Lethal Company_Data/Managed
Copy-Item (Join-Path $lethalCompanyPath "Lethal Company_Data/Managed/*") $unprocessedPath -Recurse -Force

# build PreprocessVisibility
dotnet build ./PreprocessVisibility/.

# PreprocessVisibility
powershell -c "PreprocessVisibility/bin/Debug/net8.0/PreprocessVisibility.exe '$unprocessedPath' '$processedPath' '$unprocessedPath' Assembly-CSharp"

# remove unprocessed
Remove-Item $unprocessedPath -Recurse -Force