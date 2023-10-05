#!/bin/bash

######################################################################
# MEDIALAB
# Syntax: medialab_upload.sh <folder_id> <file_path> <filename>
######################################################################

SCRIPT_PATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)"

exit_on_error() {
    echo "##################################"
    echo "       MediaLab Uploader          "
    echo "##################################"
    echo "$1"
    exit 1
}

CMD_PYTHON=python3
if command -v python3.6 &>/dev/null; then CMD_PYTHON=python3.6; fi
if ! command -v ${CMD_PYTHON} &>/dev/null; then
    exit_on_error "Python executable not found (python3), required for processing JSON."
fi

if [ -z "$1" ] || [ -z "$2" ]; then
    exit_on_error "No file given, syntax: medialab_upload.sh <folder_id> <file> <filename>"
fi

if [ ! -f "$2" ]; then
    exit_on_error "File not found: ${2}"
fi

if [ -f "${SCRIPT_PATH}/medialab.env" ]; then
    source "${SCRIPT_PATH}/medialab.env"
fi

if [ -z "$MEDIALAB_URL" ]; then
    exit_on_error "No MediaLab URL found. Please copy medialab.env.example to medialab.env and provide correct settings."
fi

if [ -z "$MEDIALAB_API_TOKEN" ]; then
    exit_on_error "No private token found. Please copy medialab.env.example to medialab.env and provide correct settings."
fi

MEDIALAB_FOLDER=$1
FILE_PATH=$2
FILE_TITLE=$3

#echo "Initializing upload to ${MEDIALAB_URL}/api/upload/id..."
ML_UPLOAD_ID_RESPONSE=$(
    curl -s -X POST "${MEDIALAB_URL}/api/upload/id" \
         -F "folder_id=${MEDIALAB_FOLDER}" \
         -H "Authorization: Private-Token ${MEDIALAB_API_TOKEN}"
)

ML_ULID_STATUS=$(echo "$ML_UPLOAD_ID_RESPONSE" | ${CMD_PYTHON} -c "import sys, json;obj=json.load(sys.stdin); print('success') if 'ulid' in obj else print(obj['error'])")

if [ "${ML_ULID_STATUS}" != "success" ]; then
    echo "ERROR: No upload URL found in response, please check URL, folder_id and token"
    echo "$ML_UPLOAD_ID_RESPONSE"
    echo "ERROR: File not uploaded (${FILE_PATH})."
    exit 1
fi

ML_URL_FILE_UPLOAD=$(echo "$ML_UPLOAD_ID_RESPONSE" | ${CMD_PYTHON} -c "import sys, json; print(json.load(sys.stdin)['url_upload_direct'])")
ML_URL_FILE_UPLOAD_ID_FINISH=$(echo "$ML_UPLOAD_ID_RESPONSE" | ${CMD_PYTHON} -c "import sys, json; print(json.load(sys.stdin)['api']['finish'])")

#echo "Upload registered with ID ${ULID}."
#echo "Starting file upload to ${ML_URL_FILE_UPLOAD}..."

ML_FILE_UPLOAD_RESPONSE=$(
    curl -s -X POST "$ML_URL_FILE_UPLOAD" \
         -F "file=@${FILE_PATH};filename=${FILE_TITLE}" \
         -F "folder_id=${MEDIALAB_FOLDER}" \
         -F "title=${FILE_TITLE}"
) || exit 1

ML_FILE_UPLOAD_STATUS=$(echo "$ML_FILE_UPLOAD_RESPONSE" | ${CMD_PYTHON} -c "import sys, json;obj=json.load(sys.stdin); print(obj['status']) if 'status' in obj else print(obj['error_description'])")

if [ "$ML_FILE_UPLOAD_STATUS" == "success" ]; then
    echo "Upload success (${FILE_PATH})"
    exit_code=0
else
    echo "ERROR: Upload failed: ${ML_FILE_UPLOAD_STATUS}"
    echo "$ML_FILE_UPLOAD_RESPONSE"
    echo "ERROR: File not uploaded (${FILE_PATH})."
    exit_code=1
fi

# Marking upload as completed
# Response value can be used to get information about uploaded files
# shellcheck disable=SC2034
ML_FILE_UPLOAD_ID_DELETE_RESPONSE=$(curl -s -X DELETE "$ML_URL_FILE_UPLOAD_ID_FINISH" -H "Authorization: Private-Token ${MEDIALAB_API_TOKEN}")

exit $exit_code
