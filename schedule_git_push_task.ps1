$obsidian_path = Read-Host "enter the obsidian exe full path:"
$vault_path = Read-Host "enter full vault path:"

# the trigger is a log of process 
$EventTriggerXmlForPull = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4688)]]
	and
*[EventData[Data[@Name='NewProcessName'] and (Data='$obsidian_path')]]
</Select>
  </Query>
</QueryList>
"@

$EventTriggerXmlForPush = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4689)]]
	and
*[EventData[Data[@Name='ProcessName'] and (Data='$obsidian_path')]]
</Select>
  </Query>
</QueryList>
"@

$push_script_path = ".\vault_git_push.ps1"
$pull_script_path = ".\vault_git_pull.ps1"
# $backupScriptPath = "C:\Users\Ariel Nathanson\Desktop\vault_git_push.ps1"

$push_action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$push_script_path`" $vault_path"
$pull_action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$pull_script_path`" $vault_path"
# $trigger = New-ScheduledTaskTrigger -Daily -At "9:00AM"

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Create the PUSH scheduled task
Register-ScheduledTask -TaskName "Git Vault Backup push Task" -Xml $EventTriggerXmlForPush
 -Description "Backs up the folder to Git repo." -Action $push_action -Principal $principal -Settings $settings

Write-Output "Scheduled task of PUSH created successfully."

# Create the PULL scheduled task
 Register-ScheduledTask -TaskName "Git Vault local update from remote Task" -Xml $EventTriggerXmlForPull
 -Description "Updates local from remote Git main branch." -Action $pull_action -Principal $principal -Settings $settings

Write-Output "Scheduled task of PULL created successfully."