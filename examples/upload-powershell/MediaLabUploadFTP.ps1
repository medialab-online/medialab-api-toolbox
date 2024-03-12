#################
# Configuration #
#################

# FTP Server Variables
$FTPHost = 'ftp://ftp.medialab.app/' # Your FTP location, should end in a slash (/)
$FTPUser = 'user'
$FTPPass = 'password'

# Directory where to find files to upload
$UploadFolder = 'C:\Users\UserName\Videos\Upload folder\'

$UploadFilesOlderThanSeconds = 10
$LogFile = 'C:\Users\UserName\Documents\MediaLab Upload FTP Log.txt'


function Log {
    param (
        $Message
    )

    if (-not(Test-Path $LogFile -PathType Leaf))
    {
        return
    }

    Write-Output "$('[{0:yyyy-MM-dd} {0:HH:mm:ss}]' -f (Get-Date)) $Message" | Out-file $LogFile -append
}

clear
Write-Output "Upload folder is $UploadFolder"
if (-not(Test-Path -Path $UploadFolder))
{
    Write-Output "[error] Upload folder does not exist"
    Exit
}

if (-not(Test-Path -Path $LogFile))
{
    Write-Output "[warning] Log file does not exist"
}

$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential($FTPUser, $FTPPass)

$SrcEntries = Get-ChildItem $UploadFolder -Recurse
$Srcfolders = $SrcEntries | Where-Object{ $_.PSIsContainer }
$SrcFiles = $SrcEntries | Where-Object{ !$_.PSIsContainer }

# Create FTP Directory/SubDirectory if needed
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
        # Folder created successfully
    }
    catch [Net.WebException]
    {
        try
        {
            # If there was an error returned, check if folder already exists on server
            $checkDirectory = [System.Net.WebRequest]::Create($DestFolder);
            $checkDirectory.Credentials = New-Object System.Net.NetworkCredential($FTPUser, $FTPPass);
            $checkDirectory.Method = [System.Net.WebRequestMethods+FTP]::PrintWorkingDirectory;
            $response = $checkDirectory.GetResponse();
            # Folder already exists
        }
        catch [Net.WebException]
        {
            # The folder didn't exist
        }
    }
}

# Upload Files
foreach ($entry in $SrcFiles)
{
    $SrcFullname = $entry.FullName
    $SrcName = $entry.Name

    if (Test-Path $SrcFullname -NewerThan (Get-Date).AddSeconds($UploadFilesOlderThanSeconds * -1))
    {
        Write-Output "Skipping file: $SrcName"
        continue
    }

    $SrcFilePath = $UploadFolder -replace "\\", "\\" -replace "\:", "\:"
    $DestFile = $SrcFullname -replace $SrcFilePath, $FTPHost
    $DestFile = $DestFile -replace "\\", "/"
    Write-Output "Uploading file: $DestFile"

    try
    {
        $uri = New-Object System.Uri($DestFile)
        $webclient.UploadFile($uri, $SrcFullname)
        Write-Output "Uploaded file: $DestFile"
        Log -Message "Uploaded file: $DestFile"

        Write-Output "Removing file: $SrcName"
        Remove-Item -Path $SrcFullname
    }
    catch
    {
        Write-Output "Error uploading file: $SrcName"
        Log -Message "Error uploading file: $DestFile"
        Write-Output $_
    }
}
