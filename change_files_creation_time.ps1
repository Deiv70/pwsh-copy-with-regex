param (
    [Parameter(Mandatory = $true)]
    [string]$path,

    [Parameter(Mandatory = $true)]
    [string]$regexPattern
)

# Precompile regex for speed
$regex = [regex]::new($regexPattern, [System.Text.RegularExpressions.RegexOptions]::Compiled)

Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
    $file = $_
    $match = $regex.Match($file.Name)

    if ($match.Success) {
        try {
            $year    = [int]$match.Groups['year'].Value
            $month   = [int]$match.Groups['month'].Value
            $day     = [int]$match.Groups['day'].Value
            $hours   = if ($match.Groups['hours'].Success)   { [int]$match.Groups['hours'].Value }   else { 0 }
            $minutes = if ($match.Groups['minutes'].Success) { [int]$match.Groups['minutes'].Value } else { 0 }
            $seconds = if ($match.Groups['seconds'].Success) { [int]$match.Groups['seconds'].Value } else { 0 }

            $date = Get-Date -Year $year -Month $month -Day $day -Hour $hours -Minute $minutes -Second $seconds
            $file.CreationTime = $date
        }
        catch {
            # ignore invalid dates silently (fast path)
        }
    }
}
