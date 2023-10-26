# PowerShell – FTP upload directory with subdirectories

Script is adapted from a
[GitHub Gist](https://gist.github.com/dkittell/f029b6c7d1c46ebcffcb)
by [David Kittell](https://github.com/dkittell).
Credits go to David Kittell.

## Setup

In the script `MediaLabUploadFTP.ps1`, fill in the following things:

- The location of your MediaLab FTP server: `$FTPHost`
- Your FTP username: `$FTPUser`
- Your password: `$FTPPass` \
  Keep in mind that if an attacker has access to the script with your password in it, the security of your account is compromised

## Running script

- Open `powershell` window
- Change directory (`cd`) to where the script is
- Run with `.\MediaLabUploadFTP.ps1`

## Running script periodically

To create a scheduled task on Windows, use these steps

- Open Start. Search for "Task Scheduler" and open the app.
- Click "Task Scheduler Library", then right-click "Task Scheduler Library" > "New Folder..." to create a folder to put our task in.
- Go to the folder you created and in the sidebar on the right under "Actions", select "Create Basic Task".
- Fill in "Name", "Description" and add a trigger, for example daily.
- Under action, select "Start a program".
- Set "Program/script" to `powershell.exe` and "Add arguments" to `-file "C:\Path\To\MediaLabUploadFTP.ps1"`,
  here replace the file path with the location of your PowerShell script.
- Complete task creation, the Task Scheduler will run the script automatically on your specified schedule.

## Warning

Before any source code or program is used, it is suggested you fully understand what it is doing.
For example, the `MediaLabUploadFTP.ps1` script removes files after uploading.
If an unexpected error occurs, data could be lost. Please keep this in mind at all times.
