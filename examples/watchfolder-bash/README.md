# MediaLab watch folder

This directory contains example scripts to set up a working watch folder system.
It relies on a periodic job to run the watcher, which will upload files to the target folder.

## Requirements

 - cURL
 - Python3

## Install

 - In MediaLab, generate a new Private Token in MediaLab > Preferences > API Access.
 - Copy `medialab.env.example` to `medialab.env` and change the Private Token and URL of your MediaLab account.
 - Make sure dependencies are installed (python / curl).
 - Set up dir structure as indicated below.
 - Set up cronjob / scheduled task: `bash /path/to/watchfolder/medialab_watcher.sh`

## Directory structure

Example directory structure: 

- `watchfolder/`
- `watchfolder/medialab.env`
- `watchfolder/medialab_upload.sh`
- `watchfolder/medialab_watcher.sh`
- `watchfolder/dropbox/`
- `watchfolder/dropbox/123456_Project_X`
- `watchfolder/dropbox/123457_Project_Y`

Different watch folders can be set up inside `dropbox`.
Each watch folder must be prefixed with the folder_id from MediaLab. 
This folder_id can be found in the API, or in your URL (browser) when you open the folder inside MediaLab.
Look for the `folder_id=XXXX` part and make note of the `XXXX`
The watcher only uses the first part of the directory name until an underscore, the rest can be used as a label for yourself.
It does not need to match the label in MediaLab.

## Notes

 - The watcher does not import a file if it has been written to less than a minute ago. This is to ensure the file is not being copied/written to anymore.
   This value can be increased if necessary.
 - The watcher appends `.lock` to a filename before it starts uploading, this is to notify that the file is in use and should not be removed.
 - If an upload has been successful, the source file will be removed. If not, the file is renamed to its original filename and will be tried again on the next run.
 - The watcher creates a lockfile of its own to prevent it running multiple times simultaneously.
 - Make sure the user belonging to the Private Token has upload rights and permission to open the chosen folders.

## License

License: [MIT](../../LICENSE)

