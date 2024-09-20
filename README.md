# auto-git-updates
Make git repo automatically up to date with powershell

# Set up
## Allow logs of process creation and termination
* open event viewer with `Win + R` then `eventvwr.msc`
* on the left side, go to *Windows Logs -> Security*
* on the right side, click `Filter Current Log`
* In the filter window, under Event IDs, enter 4688 (event ID for a new process creation) and then 4689 (event ID for a process termination).
* click *OK*
### if you don't see any logs:
* open registry editor with `Win + R` then `regedit`
* search for `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit`
* If the *Audit* key doesn't exist, right-click on the *System* key, select *New > Key*, and name it *Audit*.
### if `ProcessCreationIncludeCmdLine_Enabled`doesn't exist:
* Within the *Audit* key, right-click in the right pane, select *New > DWORD (32-bit) Value*.
* Name the value *ProcessCreationIncludeCmdLine_Enabled*.
* Set its value to `1` (this enables auditing of process creation).
### if `ProcessTermination`doesn't exist:
* Within the *Audit* key, right-click in the right pane, select *New > DWORD (32-bit) Value*.
* Name the value *ProcessTermination*.
* Set its value to `1` (this enables auditing of process termination).
![alt text](registry_values.png)
### enable process auditing
* open CMD as admin
* run `auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable`
* verify the setting by running: `auditpol /get /subcategory:"Process Creation"`
* run `auditpol /set /subcategory:"Process Termination" /success:enable /failure:enable`
* verify the setting by running: `auditpol /get /subcategory:"Process Termination"`
### verify logs in event viewer
* open and close random app, return to event viewer and refresh (`F5`) to see the logs.