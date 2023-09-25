import {MEDIA_LAB_PRIVATE_TOKEN} from './config.js';
import displayUserMessage from './helpers/messages.js';
import {
    createFolder,
    registerNewUpload,
    uploadFile,
    finishUpload,
} from './api.js';

const uploadForm = document.querySelector('#file-upload-form');
const formSubmit = uploadForm.querySelector('[type=submit]');
const methodSelection = document.querySelector('#method-selection');

(function initialize() {
    if (!MEDIA_LAB_PRIVATE_TOKEN || MEDIA_LAB_PRIVATE_TOKEN.length === 0) {
        return displayUserMessage(new Error('Please specify your private token in config.js'));
    }

    displayUserMessage('✅ main.js has loaded.');
    uploadForm.addEventListener('submit', handleFormSubmit);
}());

/**
 * This function
 * - handles the form submit event
 * - sets the method that user has selected
 * - constructs formData and an array of files from form
 * - calls the selected method
 *
 * @param {Event} event - Form submit event
 * @returns {Promise<void>}
 */
async function handleFormSubmit(event) {
    event.preventDefault(); // Enable custom handling of form submit
    formSubmit.disabled = true; // Prevent double submit
    displayUserMessage('Handling form submit.');

    const formData = new FormData(this);
    const files = Array.from(formData.getAll('files'))
        .filter((file) => file.name.length > 0 && file.size > 0);

    if (files.length === 0) {
        return displayUserMessage(new Error('No files selected.'));
    }

    const activeTabId = methodSelection.querySelector('[aria-selected="true"]').id;

    switch (activeTabId.replace(/-tab$/, '')) {
        case 'new-folder':
            displayUserMessage('Using new folder method.')
            await newFolderMethod(formData, files);
            break;
        case 'existing-folder':
            displayUserMessage('Using existing folder method.')
            await existingFolderMethod(formData, files);
            break;
        default:
            displayUserMessage('Warning: Could not determine method, using default method');
            await newFolderMethod(formData, files);
    }

    formSubmit.disabled = false;
}

/**
 * This function creates a new folder and then calls `uploadFilesToFolder` to upload files to the new folder
 *
 * @param {FormData} formData - Form data
 * @param {File[]} files - Files to be uploaded
 * @returns {Promise<void>}
 */
async function newFolderMethod(formData, files) {
    const folderName = formData.get('folder-name');
    const parentFolderId = formData.get('parent-folder-id');
    displayUserMessage('Create folder to store upload in.');
    const parentFolder = await createFolder(folderName, parentFolderId);
    if (!parentFolder) {
        return displayUserMessage(new Error('Could not create folder'));
    }

    displayUserMessage('Created folder');
    displayUserMessage(parentFolder);

    await uploadFilesToFolder(parentFolder.folder_id, files);
}

/**
 * This function gets the existing folder ID from formData and then calls `uploadFilesToFolder` to upload files
 *
 * @param {FormData} formData - Form data
 * @param {File[]} files - Files to be uploaded
 * @returns {Promise<void>}
 */
async function existingFolderMethod(formData, files) {
    const folderId = formData.get('existing-folder-id');
    await uploadFilesToFolder(folderId, files);
}

/**
 * This function registers a new upload queue to the folder with specified ID,
 * then uploads files to the upload URL returned from the server,
 * finally it reports the upload as finished to the server and displays shareable links to the user
 *
 * @param {string} folderId - The folder ID to upload files to
 * @param {File[]} files - Files to be uploaded
 * @returns {Promise<void>}
 */
async function uploadFilesToFolder(folderId, files) {
    const {
        url_upload_direct: uploadUrl,
        ulid: uploadId,
    } = await handleRegisterNewUpload(folderId);

    await uploadFiles(uploadUrl, files);

    const finishedUploadResult = await finishUpload(uploadId);
    displayUserMessage('Finished upload');
    displayUserMessage(finishedUploadResult);

    if (!Array.isArray(finishedUploadResult.files)) return;
    displayUserMessage('View the shareable URL for file title');
    finishedUploadResult.files
        .filter((file) => file.title && file.urls && file.urls.file)
        .forEach((file) => displayUserMessage(
            `File: "${file.title}", URL:`,
            new URL(file.urls.file),
        ));
}

/**
 * This function handles the API call to register new upload, logs errors if needed
 *
 * @param {string} parentFolderId
 * @returns {Promise<Object>}
 */
async function handleRegisterNewUpload(parentFolderId) {
    displayUserMessage('Registering new upload.');
    const registeredUpload = await registerNewUpload(parentFolderId);
    if (!registeredUpload || !registeredUpload.url_upload_direct) {
        return displayUserMessage(new Error('Could not register upload'));
    }
    displayUserMessage('Registered upload successfully');
    displayUserMessage(registeredUpload);

    return registeredUpload;
}

/**
 * This function handles the API calls to upload a file to the provided uploadUrl, logs errors if needed
 *
 * @param uploadUrl
 * @param files
 * @returns {Promise<boolean>}
 */
async function uploadFiles(uploadUrl, files) {
    displayUserMessage(`Uploading ${files.length} file${files.length === 1 ? '' : 's'}.`);
    displayUserMessage(`Uploading to: ${uploadUrl}`);

    const uploadedFiles = await Promise.all(files.map((file) => {
        displayUserMessage(`Uploading file: ${file.name}.`);
        return uploadFile(uploadUrl, file);
    }));

    displayUserMessage(`Finished uploading ${files.length} file${files.length === 1 ? '' : 's'}.`);
    displayUserMessage(uploadedFiles);

    const failedUploads = uploadedFiles.filter(
        (uploadedFile) => uploadedFile.status !== 'success',
    );

    const success = failedUploads.length === 0;

    if (success) {
        displayUserMessage('Successfully uploaded all files 😀');
    } else {
        displayUserMessage(new Error('Failed upload for some files.'));
        displayUserMessage(failedUploads);
    }

    return success;
}
