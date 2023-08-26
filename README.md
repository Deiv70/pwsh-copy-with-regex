# pwsh-copy-with-regex

This is a PowerShell Utility that will take from a `-sourcePath`, to the `-destinationPath` the files that matches the `-regexPattern` you want.
- You can keep the Timestamp of the source files, or get it from the regex pattern (using named capture groups), with the `-datesFromRegex` switch.
    - The needed named capture groups are: `year`, `month`, `day`, `hours`, `minutes`, `seconds`. For example: 
        ```regex
        (?:IMG|VID)[_-](?<year>\d{4})(?<month>\d{2})(?<day>\d{2})[_-](?<hours>\d{2})(?<minutes>\d{2})(?<seconds>\d{2}).(?:JPE?G|MP4|jpe?g|mp4)$
        ```
- You can avoid replication of the folder structure by using the `-noDestinationFolderNesting` switch.
