# Make a c:\Utilies directory
New-Item -Path "c:\Utilities" -ItemType "directory" -Force

# REST call to get contents of the storage account blob container at https://ctcdownloads.blob.core.windows.net/classsetup
$uri = "https://ctcdownloads.blob.core.windows.net/classsetup?restype=container&comp=list"
$response = Invoke-RestMethod -Uri $uri -Method Get -Headers @{"x-ms-version"="2017-11-09";"x-ms-date"=$(Get-Date -Format u);"x-ms-blob-type"="BlockBlob";"Accept-Encoding"="UTF-8"}

# convert xml in response to an object
[xml]$response = $response


# Enumerate the blobs in the response and download them to the c:\Utilities directory



$blobs = $response.EnumerationResults.Blobs.Blob
$blobs | ForEach-Object {
    $blob = $_
    $blobName = $blob.Name
    $localFileName = "c:\Utilities\$blobName"
    $blobUri = "https://ctcdownloads.blob.core.windows.net/classsetup/$blobName"
    Start-BitsTransfer -Source $blobUri -Destination $localFileName
}
 
# Apply the c:\Utilities\ZoomitConfig.reg file to the registry
regedit /s c:\Utilities\ZoomitConfig.reg

# Make an array of URLs to download
$urls = @(
    "https://ctcdownloads.blob.core.windows.net/installers/npp.8.5.8.Installer.x64.exe",
    "https://ctcdownloads.blob.core.windows.net/installers/VSCodeSetup-x64-1.83.1.exe"
)

# Download the files in the array to the downloads directory
$downloadsDir = [System.Environment]::GetFolderPath("Downloads")
$urls | ForEach-Object {
    $url = $_
    $fileName = $url.Split("/")[-1]
    $localFileName = "$downloadsDir\$fileName"
    Invoke-WebRequest -Uri $url -OutFile $localFileName
}

# Install the downloaded files
$downloadsDir = [System.Environment]::GetFolderPath("Downloads")
$installers = @(
    { path = "$downloadsDir\npp.8.5.8.Installer.x64.exe", args = "/S" },
    { path = "$downloadsDir\VSCodeSetup-x64-1.83.1.exe", args = "/VERYSILENT /NORESTART /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders" }
)

$installers | ForEach-Object {
    $installer = $_
    Start-Process -FilePath $installer.path -ArgumentList $installer.args -Wait
}

# Launch c:\Utilities\ZoomIt.exe
Start-Process -FilePath "c:\Utilities\ZoomIt.exe"
 
# Launch c:\Utilities\artwork_wide.pptx
Start-Process -FilePath "c:\Utilities\artwork_wide.pptx"