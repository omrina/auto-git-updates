$folderPath = $args[0];
Set-Location -Path $folderPath;

git pull origin main

Write-Output "OmriVault updated locally from remote main." ;