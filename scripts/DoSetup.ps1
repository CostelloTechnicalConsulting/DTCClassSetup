# Make a c:\Utilies directory
New-Item -Path "c:\Utilities" -ItemType "directory" -Force

# Get a list of the contents of the storage account blob container at https://ctcdownloads.blob.core.windows.net/classsetup
$context = New-AzStorageContext -StorageAccountName "ctcdownloads" -StorageAccountKey "Pvgp2hmdw39ooAe/KAljc8xU35reLkZMSkNv9AZDx370Xe96Hpz/u4GtoXJ9KaXeQLNmhvGbvCIGiVbMyPjNWw=="
$container = Get-AzStorageContainer -Context $context -Name "classsetup"
$blobs = Get-AzStorageBlob -Container $container.Name -Context $context
$blobs | ForEach-Object { $_.Name }

# Download the files from the storage account blob container to the c:\Utilities directory

$blobs | ForEach-Object {
    $blobName = $_.Name
    $localFileName = "c:\Utilities\$blobName"
    Get-AzStorageBlobContent -Container $container.Name -Blob $blobName -Context $context -Destination $localFileName
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