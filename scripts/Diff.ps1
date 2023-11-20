# ensure octodiff is built
if (-not (Test-Path .\OctodiffCli\bin\Debug\net8.0\OctodiffCli.exe)) {
    Write-Host "Building octodiff.exe"
    dotnet build .\OctodiffCli\OctodiffCli.csproj -c Debug -f net8.0
}

# inherit args to OctodiffCli.exe
if ($args.Length -eq 0) {
    Start-Process .\OctodiffCli\bin\Debug\net8.0\OctodiffCli.exe -NoNewWindow -Wait
} else {
    Start-Process .\OctodiffCli\bin\Debug\net8.0\OctodiffCli.exe -ArgumentList $args -NoNewWindow -Wait
}