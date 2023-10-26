clear

# FTP Server Variables
$FTPHost = 'ftp://ftp.medialab.app/' # Your FTP location, should end in a slash (/)
$FTPUser = 'user'
$FTPPass = 'password'

# Directory where to find files to upload
$UploadFolder = "C:\Users\UserName\Videos\Upload folder\"
Write-Output "Upload folder is $UploadFolder"

if (-not(Test-Path -Path $UploadFolder))
{
    "Upload folder does not exist"
    Exit
}

$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential($FTPUser, $FTPPass)

$SrcEntries = Get-ChildItem $UploadFolder -Recurse
$Srcfolders = $SrcEntries | Where-Object{ $_.PSIsContainer }
$SrcFiles = $SrcEntries | Where-Object{ !$_.PSIsContainer }

# Create FTP Directory/SubDirectory If Needed
foreach ($folder in $Srcfolders)
{
    $SrcFolderPath = $UploadFolder -replace "\\", "\\" -replace "\:", "\:"
    $DestFolder = $folder.Fullname -replace $SrcFolderPath, $FTPHost
    $DestFolder = $DestFolder -replace "\\", "/"
    Write-Output "Creating remote folder: $DestFolder"

    try
    {
        $makeDirectory = [System.Net.WebRequest]::Create($DestFolder);
        $makeDirectory.Credentials = New-Object System.Net.NetworkCredential($FTPUser, $FTPPass);
        $makeDirectory.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory;
        $makeDirectory.GetResponse();
        #folder created successfully
    }
    catch [Net.WebException]
    {
        try
        {
            # if there was an error returned, check if folder already existed on server
            $checkDirectory = [System.Net.WebRequest]::Create($DestFolder);
            $checkDirectory.Credentials = New-Object System.Net.NetworkCredential($FTPUser, $FTPPass);
            $checkDirectory.Method = [System.Net.WebRequestMethods+FTP]::PrintWorkingDirectory;
            $response = $checkDirectory.GetResponse();
            # folder already exists!
        }
        catch [Net.WebException]
        {
            # if the folder didn't exist
        }
    }
}

# Upload Files
foreach ($entry in $SrcFiles)
{
    $SrcFullname = $entry.fullname
    $SrcName = $entry.Name
    $SrcFilePath = $UploadFolder -replace "\\", "\\" -replace "\:", "\:"
    $DestFile = $SrcFullname -replace $SrcFilePath, $FTPHost
    $DestFile = $DestFile -replace "\\", "/"
    Write-Output "Uploading file: $DestFile"

    $uri = New-Object System.Uri($DestFile)
    $webclient.UploadFile($uri, $SrcFullname)

    Write-Output "Removing file: $SrcName"
    Remove-Item -Path $SrcFullname
}
