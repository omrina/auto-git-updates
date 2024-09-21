$folderPath = $args[0];
$app_name = $args[1]
Set-Location -Path $folderPath;

git pull origin main

Write-Output "$app_name pulled from remote main." ;