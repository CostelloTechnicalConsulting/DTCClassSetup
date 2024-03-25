$blobContainerURL = "https://ctcdownloads.blob.core.windows.net/classsetup"
$guid = [guid]::NewGuid().ToString()
$tempXMLFile = "$env:TEMP\$guid-temp.xml"

# Make a c:\Utilies directory
New-Item -Path "c:\Utilities" -ItemType "directory" -Force

# Use Storage account APIs to list out contents of the container
# Write the output to a temp file
Invoke-RestMethod -Uri $($blobContainerURL + "?restype=container&comp=list") -Method Get -OutFile $tempXMLFile
# Read it back in as XML (UTF8 encoded)
[xml]$xmlData = get-content $tempXMLFile -Encoding "utf8"


# Enumerate the blobs in the response and download them to the c:\Utilities directory
# Get the list of blobs
$blobs = $xmlData.EnumerationResults.Blobs.Blob
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
$downloadsDir = "$env:USERPROFILE\Downloads"
$urls | ForEach-Object {
    $url = $_
    $fileName = $url.Split("/")[-1]
    $localFileName = "$downloadsDir\$fileName"
    Invoke-WebRequest -Uri $url -OutFile $localFileName
}

# Install the downloaded files
$downloadsDir = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
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