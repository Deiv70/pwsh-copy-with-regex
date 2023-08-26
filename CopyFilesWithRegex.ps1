param (
    [Parameter(Mandatory = $true)]
    [string]$sourcePath,

    [Parameter(Mandatory = $true)]
    [string]$regexPattern,
    # Good Example: '(?:IMG|VID)[_-](?<year>\d{4})(?<month>\d{2})(?<day>\d{2})[_-](?<hours>\d{2})(?<minutes>\d{2})(?<seconds>\d{2}).(?:JPE?G|MP4|jpe?g|mp4)$'
    # Example including WhatsApp old format: '(?:IMG|VID)[_-](?<year>\d{4})(?<month>\d{2})(?<day>\d{2})[_-](?:(?<hours>\d{2})(?<minutes>\d{2})(?<seconds>\d{2})|WA\d{4}).(?:JPE?G|MP4|jpe?g|mp4)$'

    [Parameter(Mandatory = $true)]
    [string]$destinationPath,

    [switch]$noDestinationFolderNesting,

    [switch]$datesFromRegex
)

# Create the output directory if it doesn't exist
if (-Not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
}

# Get files from the source directory
$files = Get-ChildItem -Path $sourcePath -Recurse | Where-Object { $_.FullName -match $regexPattern -and -Not $_.PSIsContainer }

foreach ($file in $files) {
    if ($datesFromRegex && $file.Name -match $regexPattern) {
        $year = [int]$Matches['year']
        $month = [int]$Matches['month']
        $day = [int]$Matches['day']
        $hours = [int]$Matches['hours']
        $minutes = [int]$Matches['minutes']
        $seconds = [int]$Matches['seconds']
    }

    # Get the relative path of the file
    $relativePath = $file.FullName.Replace($sourcePath, '').TrimStart('\')

    if ($noDestinationFolderNesting) {
        $relativePath = $file.Name
    }

    # Determine the destination path
    $destinationFile = Join-Path -Path $destinationPath -ChildPath $relativePath

    # Create the destination directory if it doesn't exist
    $destinationDir = Split-Path $destinationFile
    if (-Not (Test-Path -Path $destinationDir)) {
        New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    }

    # Copy the file and preserve timestamps
    Copy-Item -Path $file.FullName -Destination $destinationFile -Force

    $creationTimestamp = $file.CreationTime
    $lastWriteTimestamp = $file.LastWriteTime
    $lastAccessTimestamp = $file.LastAccessTime

    if ($datesFromRegex) {
        $creationTimestamp = Get-Date -Year $year -Month $month -Day $day -Hour $hours -Minute $minutes -Second $seconds
        $lastWriteTimestamp = $creationTimestamp
        $lastAccessTimestamp = $creationTimestamp
    }

    (Get-Item $destinationFile).CreationTime = $creationTimestamp
    (Get-Item $destinationFile).LastWriteTime = $lastWriteTimestamp
    (Get-Item $destinationFile).LastAccessTime = $lastAccessTimestamp
}
