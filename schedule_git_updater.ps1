if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "you must run this as administrator! exiting..."
  exit
}

Write-Output "Welcome to auto git updates!"
Write-Output "first we need to do some set up:"
Write-Output ""
Write-Output "enabling process creation logs..."
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
Write-Output ""
Write-Output "enabling process termination logs..."
auditpol /set /subcategory:"Process Termination" /success:enable /failure:enable

Write-Output ""
Write-Output "next step, give us some info:"
$app_path = Read-Host "enter the app exe full path"
$git_path = Read-Host "enter git repo full path"
$app_name = Read-Host "enter app name for task readability"
$push_script_path = "$PSScriptRoot\git_push.ps1"
$pull_script_path = "$PSScriptRoot\git_pull.ps1"
$current_user = $Env:UserName

$pullTaskXml = @"
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>$(Get-Date -Format "yyyy-MM-ddTHH:mm:ss")</Date>
    <Author>$current_user</Author>
    <Description>$app_name pull from git when app starts</Description>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>
      &lt;QueryList&gt;&lt;Query Id="0" Path="Security"&gt;&lt;Select Path="Security"&gt;*[System[(EventID=4688)]]
              and
            *[EventData[Data[@Name='NewProcessName'] and (Data='$app_path')]]
            &lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$current_user</UserId>
      <LogonType>S4U</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <StartWhenAvailable>true</StartWhenAvailable>
    <AllowHardTerminate>true</AllowHardTerminate>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-File `"$pull_script_path`" $git_path $app_name</Arguments>
    </Exec>
  </Actions>
</Task>
"@

$pushTaskXml = @"
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>$(Get-Date -Format "yyyy-MM-ddTHH:mm:ss")</Date>
    <Author>$current_user</Author>
    <Description>$app_name push to git when app terminates</Description>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>
        &lt;QueryList&gt;&lt;Query Id="0" Path="Security"&gt;&lt;Select Path="Security"&gt;*[System[(EventID=4689)]]
              and
            *[EventData[Data[@Name='ProcessName'] and (Data='$app_path')]]
            &lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$current_user</UserId>
      <LogonType>S4U</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <StartWhenAvailable>true</StartWhenAvailable>
    <AllowHardTerminate>true</AllowHardTerminate>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-File `"$push_script_path`" $git_path $app_name</Arguments>
    </Exec>
  </Actions>
</Task>
"@

Register-ScheduledTask -TaskName "$app_name push task" -Xml $pushTaskXml
Write-Output "Scheduled task of PUSH created successfully."
Register-ScheduledTask -TaskName "$app_name pull task" -Xml $pullTaskXml
Write-Output "Scheduled task of PULL created successfully."
Write-Output "All done! enjoy :-)"