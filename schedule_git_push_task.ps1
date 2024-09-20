# Define the path to the backup script
$backupScriptPath = "C:\Users\Ariel Nathanson\Desktop\vault_git_push.ps1"

# Define the task name and description
$taskName = "Git Vault Backup Task"
$taskDescription = "Automatically backs up the folder to Git daily."

# Define the action to run the backup script
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File "$backupScriptPath""

# Define the trigger to run daily at 9:00 AM
$trigger = New-ScheduledTaskTrigger -Daily -At "9:00AM"

# Define the principal to run the task with highest privileges
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Define the settings for the scheduled task
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Create the scheduled task
Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Action $action -Trigger $trigger -Principal $principal -Settings $settings

Write-Output "Scheduled task '$taskName' created successfully."