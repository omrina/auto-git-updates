$folderPath = $args[0];
$app_name = $args[1]
Set-Location -Path $folderPath;

git add . ;

$commitMessage = "Backup on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')";
git commit -m $commitMessage ;

git push ;

Write-Output "$app_name backup completed and pushed to Git repository." ;