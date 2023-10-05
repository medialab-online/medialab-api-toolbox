#!/bin/bash

######################################################################
# MEDIALAB
######################################################################
# Requirements:
# - cURL
# - Python3 (to parse the API results)
#
# How to use:
# - Generate Private Token in MediaLab > Preferences > API Access
# - Copy medialab.env.example to medialab.env
# - Set Private Token and Lab URL in medialab.env
# - Set up watch dir structure as indicated below
# - Set up cronjob or scheduled task inside NAS/Synology to execute this script periodically
#
# - Dependencies
#
# Watch dir structure:
# - dropbox/
# - dropbox/<MEDIALAB_FOLDER_ID>_FolderLabel
# - dropbox/<MEDIALAB_FOLDER_ID_2>_Project_X
# - dropbox/<MEDIALAB_FOLDER_ID_3>_Project_Y
#
# Note: after the folder_id, any text can be put after the underscore to use as a label.
# It will then proceed to upload the files to the given folder id.
# The folder_id can be taken from the URL when logged in to MediaLab (look for "folder_id=XXXXX").
# We only process files older than 1 minute to make sure the file is no longer being written to.
######################################################################

SCRIPT_PATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)"

SOURCE="${SCRIPT_PATH}/dropbox/"
LOCKFILE="${SCRIPT_PATH}/medialab_watcher.lock"
# Number of minutes to wait before importing a file.
WATCHER_FILE_AGE_MIN=1

exit_on_error() {
    echo "##################################"
    echo "        MediaLab Watcher          "
    echo "##################################"
    echo "$1";
    exit 1;
}

exec 100>"$LOCKFILE" || exit_on_error "Lock failed."
flock -w 5 100 || exit_on_error "Lock failed, watcher is already running"
trap 'rm -f $LOCKFILE' EXIT

files="$(find "$SOURCE" -maxdepth 2 -type f -cmin +${WATCHER_FILE_AGE_MIN} -not -name '*.lock' -not -name '.gitkeep')"

if [ -z "$files" ]; then
#		echo "No files found, exiting."
		rm -f "${LOCKFILE}"
		exit 0;
fi

while IFS= read -r file_path; do
	if [ -z "$file_path" ]; then
            echo "No filename received, exiting."
            break;
    fi
    echo "Processing file: ${file_path}"
    target_folder_id=$(basename "$(dirname "${file_path}")")
    target_folder_id=${target_folder_id%%_*}

    file_basename=$(basename -- "$file_path")
    file_path_tmp="${file_path}.lock"
    mv "$file_path" "${file_path_tmp}"
    echo "Uploading file ${file_basename} to target folder ${target_folder_id}.."

	# the filename is specified separately to strip the .lock suffix
    if "${SCRIPT_PATH}/medialab_upload.sh" "$target_folder_id" "${file_path_tmp}" "${file_basename}"; then
        rm -f "${file_path_tmp}"
		echo "Finished uploading ${file_path}."
    else
        mv "${file_path_tmp}" "${file_path}"
		echo "Error while uploading ${file_path}."
    fi

done <<< "$files"

rm -f "${LOCKFILE}"
