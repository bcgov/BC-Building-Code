param(
    [string]$XmlFolder = "json-generation-pipeline/source"
)

Write-Host "Checking graphics references in XML files..." -ForegroundColor Cyan
Write-Host ""

# Find all XML files
$xmlFiles = Get-ChildItem -Path $XmlFolder -Filter "*.xml" -Recurse -File

$allGraphics = @{}
$missingFiles = @()
$foundFiles = @()

foreach ($xmlFile in $xmlFiles) {
    $content = Get-Content $xmlFile.FullName -Raw
    
    # Extract all graphic src attributes
    $matches = [regex]::Matches($content, 'graphic\s+src="([^"]+)"')
    
    foreach ($match in $matches) {
        $graphicPath = $match.Groups[1].Value
        
        if (-not $allGraphics.ContainsKey($graphicPath)) {
            $allGraphics[$graphicPath] = @()
        }
        
        $allGraphics[$graphicPath] += $xmlFile.Name
    }
}

Write-Host "Found $($allGraphics.Count) unique graphic references" -ForegroundColor Yellow
Write-Host ""

# Check if files exist
foreach ($graphicPath in $allGraphics.Keys | Sort-Object) {
    $fullPath = Join-Path (Get-Location) $graphicPath
    $exists = Test-Path $fullPath
    
    # Also check for JPG version
    $jpgPath = $graphicPath -replace '\.eps$', '.jpg'
    $fullJpgPath = Join-Path (Get-Location) $jpgPath
    $jpgExists = Test-Path $fullJpgPath
    
    $status = if ($exists -and $jpgExists) {
        "[EPS+JPG]"
        $foundFiles += $graphicPath
    } elseif ($exists) {
        "[EPS only]"
        $foundFiles += $graphicPath
    } elseif ($jpgExists) {
        "[JPG only - EPS missing]"
        $missingFiles += $graphicPath
    } else {
        "[MISSING]"
        $missingFiles += $graphicPath
    }
    
    $color = if ($exists -or $jpgExists) { "Green" } else { "Red" }
    
    Write-Host "$status $graphicPath" -ForegroundColor $color
    Write-Host "  Referenced in: $($allGraphics[$graphicPath] -join ', ')" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Total unique graphics: $($allGraphics.Count)"
Write-Host "  Found (EPS or JPG): $($foundFiles.Count)" -ForegroundColor Green
Write-Host "  Missing: $($missingFiles.Count)" -ForegroundColor $(if ($missingFiles.Count -gt 0) { "Red" } else { "Green" })
Write-Host "========================================" -ForegroundColor Cyan

if ($missingFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "Missing files:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
}
