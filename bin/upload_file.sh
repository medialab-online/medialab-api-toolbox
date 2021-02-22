#!/bin/bash
######################################################################
# MEDIALAB
######################################################################
#
# This is an example Bash script on uploading files to MediaLab from the command line.
# This example uses cURL to execute requests and Python to parse JSON from the API.
#
# Please obtain a Private Token through your Profile page first.
# You can obtain the folder ID by navigation to the folder, then going to Details.
#
MEDIALAB_API_URL="https://YOUR-TENANT.medialab.app/api"
MEDIALAB_API_TOKEN="PRIVATE-TOKEN"
MEDIALAB_FOLDER=123456

if [ -z "$1" ]; then
        echo "No file given, syntax: upload_file.sh <file> [title]"
        exit 1
fi

if [ ! -f "$1" ]; then
        echo "File not found: ${1}"
        exit 1
fi

FILE_PATH=$1
FILE_TITLE=$2

echo "Initializing upload to ${MEDIALAB_API_URL}/upload/id..."
FILE_UPLOAD_ID_RESPONSE=$( \
        curl -X POST ${MEDIALAB_API_URL}/upload/id \
        -F "folder_id=${MEDIALAB_FOLDER}" \
        -H "Authorization: Private-Token ${MEDIALAB_API_TOKEN}" )

ULID=$(echo "$FILE_UPLOAD_ID_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['ulid'])" )
URL_FILE_UPLOAD=$(echo "$FILE_UPLOAD_ID_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['url_upload_direct'])" )
URL_FILE_UPLOAD_ID_FINISH=$(echo "$FILE_UPLOAD_ID_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['api']['finish'])" )

if [ -z "$URL_FILE_UPLOAD" ]; then
        echo "No upload URL found in response, please check URL and token"
        exit 1
fi

echo "Upload registered with ID ${ULID}."
echo "Starting file upload to ${URL_FILE_UPLOAD}..."
FILE_UPLOAD_RESPONSE=$( \
        curl -X POST ${URL_FILE_UPLOAD} \
        -F "file=@${FILE_PATH}" \
        -F "folder_id=${MEDIALAB_FOLDER}" \
        -F "title=${FILE_TITLE}" )

URL_FILE_SHARE=$(echo "$FILE_UPLOAD_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['api']['share'])" )
if [ -z "$URL_FILE_SHARE" ]; then
        echo "Unable to retrieve file share URL from upload API"
        exit 1
fi


echo "Marking upload as completed (through ${URL_FILE_UPLOAD_ID_FINISH}).."
FILE_UPLOAD_ID_DELETE_RESPONSE=$(curl -X DELETE ${URL_FILE_UPLOAD_ID_FINISH} -H "Authorization: Private-Token ${MEDIALAB_API_TOKEN}" )

echo "Generating direct share link to source file..."
FILE_SHARE_URL_DIRECT=$( \
        curl ${URL_FILE_SHARE} -H "Authorization: Private-Token ${MEDIALAB_API_TOKEN}" \
        | python3 -c "import sys, json; print(json.load(sys.stdin)['objects']['file']['url'])" )

echo "Direct link: ${FILE_SHARE_URL_DIRECT}"
