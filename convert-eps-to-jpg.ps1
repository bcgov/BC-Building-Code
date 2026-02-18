param(
    [Parameter(Mandatory=$true)]
    [string]$ParentFolder
)

# Check if parent folder exists
if (-not (Test-Path $ParentFolder)) {
    Write-Error "Parent folder '$ParentFolder' does not exist"
    exit 1
}

# Check if Ghostscript is available
$gsCommand = "gswin64c.exe"
try {
    & $gsCommand -version 2>&1 | Out-Null
} catch {
    Write-Error "Ghostscript (gswin64c.exe) not found. Please install Ghostscript first."
    exit 1
}

# Find all .eps files recursively
$epsFiles = Get-ChildItem -Path $ParentFolder -Filter "*.eps" -Recurse -File

if ($epsFiles.Count -eq 0) {
    Write-Host "No .eps files found in '$ParentFolder'"
    exit 0
}

Write-Host "Found $($epsFiles.Count) .eps file(s) to convert"
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($epsFile in $epsFiles) {
    $outputFile = Join-Path $epsFile.DirectoryName "$($epsFile.BaseName).jpg"
    
    Write-Host "Converting: $($epsFile.FullName)"
    Write-Host "       To: $outputFile"
    
    try {
        & $gsCommand -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -r300 -dEPSCrop -sOutputFile="$outputFile" "$($epsFile.FullName)" 2>&1 | Out-Null
        
        if (Test-Path $outputFile) {
            Write-Host "  [SUCCESS]" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "  [FAILED] Output file not created" -ForegroundColor Red
            $failCount++
        }
    } catch {
        Write-Host "  [FAILED] $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
    
    Write-Host ""
}

Write-Host "========================================"
Write-Host "Conversion complete!"
Write-Host "  Success: $successCount" -ForegroundColor Green
if ($failCount -gt 0) {
    Write-Host "  Failed:  $failCount" -ForegroundColor Red
} else {
    Write-Host "  Failed:  $failCount" -ForegroundColor Green
}
Write-Host "========================================"
