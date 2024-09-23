# auto-git-updates
Make your git repo automatically up to date with powershell!
## This tool creates 2 scheduled tasks:
*First choose an app (for example *notepad*)
1. When the app you chose is **launched** OR you **log in** to computer -> perform `git pull`
2. When the app you chose is **closed** OR **every 30 minutes** -> perform `git add & commit & push`

The app launch and close and the computer logon are triggers the task by event log of process creation, process termination and account logon.  

> **_NOTE:_**  It's assumed your default branch is **main**.  
> If you wish to change it, edit `git_pull.ps1` line 5 and change the branch.  
  
## Installation  
* Open CMD as **admin**.  
* Run `powershell schedule_git_updater.ps1`.  
* Follow 2 simple input prompts (app path & repo path)  

# Enjoy! :)
