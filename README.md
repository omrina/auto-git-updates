# auto-git-updates
Make your git repo automatically up to date with powershell:
* Choose an app (for example *notepad*).
* When the app you chose is **launched** -> perform `git pull`.
* When the app you chose is **closed** -> perform `git add & commit & push`.
* It's all performed with Windows' **schedule tasks** for pull and for push, triggered by event log of process creation and process termination.

> **_NOTE:_**  It's assumed your default branch is **main**.  
> if you wish to change it, edit `git_pull.ps1` line 5 and change the branch there.

# Run
* open CMD as **admin**.
* run `powershell schedule_git_updater.ps1`.
* follow the 3 simple input prompts (app path, repo path & app name)
* Enjoy! :)
