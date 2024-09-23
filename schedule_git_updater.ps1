if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "you must run this as administrator! exiting..."
  exit
}

Write-Output "Welcome to auto git updates!"
Write-Output ""
Write-Output "first we need to do some set up:"
Write-Output "enabling process CREATION logs..."
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
Write-Output "enabling process TERMINATION logs..."
auditpol /set /subcategory:"Process Termination" /success:enable /failure:enable
Write-Output "enabling process LOGON logs..."
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /category:"Account Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Special Logon" /success:enable /failure:enable

Write-Output ""
Write-Output "final step, give us some info:"
$app_path = Read-Host "enter the app exe full path"
$git_path = Read-Host "enter git repo full path"
$git_folder_name = ($git_path -split '\\')[-1]
$app_name = [System.IO.Path]::GetFileNameWithoutExtension($app_path)
$push_script_path = "$PSScriptRoot\git_push.ps1"
$pull_script_path = "$PSScriptRoot\git_pull.ps1"
$current_user = (Get-WmiObject -Class Win32_ComputerSystem).UserName

function SchedulePushOnAppCloseAndEvery30Min {
  $pushTaskXml = @"
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>$(Get-Date -Format "yyyy-MM-ddTHH:mm:ss")</Date>
    <Author>$current_user</Author>
    <Description>$app_name push to git when app terminates and every 30 minutes</Description>
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
    <TimeTrigger>
        <Enabled>true</Enabled>
        <StartBoundary>$(Get-Date -Format "yyyy-MM-ddTHH:mm:ss")</StartBoundary>
        <Repetition>
            <Interval>PT30M</Interval>
        </Repetition>
    </TimeTrigger>
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

  if (-not $(Get-ScheduledTask -TaskName "$git_folder_name git push by $app_name" -ErrorAction SilentlyContinue)) {
    Register-ScheduledTask -TaskName "$git_folder_name git push by $app_name" -Xml $pushTaskXml
    Write-Output "Scheduled task of 'PUSH' created successfully."
  }
  else {
    Write-Output "Scheduled task of 'PUSH' already exists, continuing..."
  }
}

function SchedulePullOnAppOpenAndOnLogon {
  $pullTaskXml = @"
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>$(Get-Date -Format "yyyy-MM-ddTHH:mm:ss")</Date>
    <Author>$current_user</Author>
    <Description>$app_name pull from git when app starts and on user logon</Description>
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
    <EventTrigger>
    <Enabled>true</Enabled>
    <Subscription>
      &lt;QueryList&gt;
        &lt;Query Id="0" Path="Security"&gt;
          &lt;Select Path="Security"&gt;
              *[System[(EventID=4624)]]
              and
              *[EventData[Data[@Name='LogonType'] and (Data='2')]]
            &lt;/Select&gt;
          &lt;/Query&gt;
      &lt;/QueryList&gt;
    </Subscription>
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

  if (-not $(Get-ScheduledTask -TaskName "$git_folder_name git pull by $app_name" -ErrorAction SilentlyContinue)) {
    Register-ScheduledTask -TaskName "$git_folder_name git pull by $app_name" -Xml $pullTaskXml
    Write-Output "Scheduled task of 'PULL' created successfully."
  }
  else {
    Write-Output "Scheduled task of 'PULL' already exists, continuing..."
  }
}

SchedulePushOnAppCloseAndEvery30Min
SchedulePullOnAppOpenAndOnLogon

Write-Output "All done! enjoy :-)"