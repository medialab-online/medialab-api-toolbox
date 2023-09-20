import displayUserMessage from './helpers/messages.js';
import {
    MEDIA_LAB_API_URI,
    MEDIA_LAB_PRIVATE_TOKEN,
} from './config.js';

const apiBase = `${MEDIA_LAB_API_URI}/api`;

/**
 * [POST] /folders/{folder_id}
 *
 * Add a new folder to the given folder_id. If the given id is 0, the folder will be added to the root.
 * This is only available for users with administrator level.
 * For adding new folders the 'manage' scope is required, and the user must have been given the 'create' flag by an
 * administrator.
 *
 * On success the new folder object will be returned.
 *
 * @param {string} folderName
 * @param {string} parentFolderId
 * @returns {Promise<Object>}
 */
export async function createFolder(folderName, parentFolderId) {
    const apiUrl = `${apiBase}/folders/${parentFolderId}`;
    const data = {name: folderName};

    try {
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Private-Token ${MEDIA_LAB_PRIVATE_TOKEN}`,
            },
            body: JSON.stringify(data),
        });

        const responseData = await response.json();

        if (!response.ok) {
            throw new Error(responseData.user_message || 'Request failed for createFolder');
        }

        return responseData;
    } catch (error) {
        displayUserMessage(error);
    }
}

/**
 * [POST] /upload/id
 * Register a new upload
 *
 * This method starts a new upload process and returns a valid upload_id required to upload new files.
 * It includes a signed URL that can be used to upload directly (without authorization) by your application users.
 * It is possible to pass a folder_id that will be used for all files uploaded with this upload id.
 * This method requires 'upload' permissions for the client.
 *
 * @returns {Promise<Object>}
 */
export async function registerNewUpload(folderId) {
    const apiUrl = `${apiBase}/upload/id`;

    // set hide_response to true if you don't want details like your user ID to leak to your public-facing front-end
    const data = {
        folder_id: folderId,
        hide_response: true,
    };

    try {
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Private-Token ${MEDIA_LAB_PRIVATE_TOKEN}`,
            },
            body: JSON.stringify(data),
        });

        const responseData = await response.json();

        if (!response.ok) {
            throw new Error(responseData.user_message || 'Request failed for registerNewUpload');
        }

        return responseData;
    } catch (error) {
        displayUserMessage(error);
    }
}

/**
 * This function uploads a single file to an upload URL
 *
 * See documentation at: https://www.medialab.app/docs/api/upload
 *
 * NOTE:
 * With `fetch`, Content-Type header should _not_ be set to multipart/form-data,
 * otherwise browser will not add necessary boundaries, see: https://stackoverflow.com/a/39281156
 *
 * @param {String} uploadUrl
 * @param {File} file
 * @returns {Promise<Object>}
 */
export async function uploadFile(uploadUrl, file) {
    // fileName can be a string of your choosing, passes system file name by default
    const fileName = file.name;
    const formData = new FormData();
    formData.append('file', file, fileName);

    try {
        const response = await fetch(uploadUrl, {
            method: 'POST',
            body: formData,
        });

        const responseData = await response.json();

        if (!response.ok) {
            throw new Error(responseData.user_message || 'Request failed for uploadFile');
        }

        return responseData;
    } catch (error) {
        displayUserMessage(error);
    }
}

/**
 * [DELETE] /upload/id/{ulid}
 * Finish an existing upload
 *
 * This method marks an existing upload_id as finished and optionally returns a list of all uploaded files.
 * This method requires 'upload' permissions for the client.
 *
 * @param {string} uploadId
 * @returns {Promise<Object>}
 */
export async function finishUpload(uploadId) {
    const apiUrl = `${apiBase}/upload/id/${uploadId}`;

    try {
        const response = await fetch(apiUrl, {
            method: 'DELETE',
            headers: {
                Authorization: `Private-Token ${MEDIA_LAB_PRIVATE_TOKEN}`,
            },
        });

        const responseData = await response.json();

        if (!response.ok) {
            throw new Error(responseData.user_message || 'Request failed for finishUpload');
        }

        return responseData;
    } catch (error) {
        displayUserMessage(error);
    }
}
