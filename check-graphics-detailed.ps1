param(
    [string]$XmlFolder = "json-generation-pipeline/source"
)

Write-Host "Checking graphics references in XML files..." -ForegroundColor Cyan
Write-Host ""

# Find all XML files
$xmlFiles = Get-ChildItem -Path $XmlFolder -Filter "*.xml" -Recurse -File

$allGraphics = @{}

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

$foundExact = 0
$foundCaseIssue = 0
$foundJpgOnly = 0
$missing = 0
$missingList = @()
$caseIssueList = @()

# Check if files exist
foreach ($graphicPath in $allGraphics.Keys | Sort-Object) {
    $fullPath = Join-Path (Get-Location) $graphicPath
    $exists = Test-Path $fullPath
    
    # Check for JPG version
    $jpgPath = $graphicPath -replace '\.eps$', '.jpg'
    $fullJpgPath = Join-Path (Get-Location) $jpgPath
    $jpgExists = Test-Path $fullJpgPath
    
    # Check case-insensitive
    $folder = Split-Path $graphicPath -Parent
    $filename = Split-Path $graphicPath -Leaf
    $caseInsensitiveMatch = $null
    
    if (Test-Path $folder) {
        $caseInsensitiveMatch = Get-ChildItem -Path $folder -Filter $filename -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    
    if ($exists -and $jpgExists) {
        Write-Host "[OK] $graphicPath" -ForegroundColor Green
        $foundExact++
    } elseif ($exists) {
        Write-Host "[EPS ONLY] $graphicPath" -ForegroundColor Yellow
        $foundExact++
    } elseif ($jpgExists) {
        Write-Host "[JPG ONLY] $graphicPath" -ForegroundColor Yellow
        $foundJpgOnly++
    } elseif ($caseInsensitiveMatch) {
        Write-Host "[CASE ISSUE] $graphicPath" -ForegroundColor Magenta
        Write-Host "  Found as: $($caseInsensitiveMatch.FullName -replace [regex]::Escape((Get-Location).Path + '\'), '')" -ForegroundColor Gray
        $foundCaseIssue++
        $caseIssueList += @{
            Expected = $graphicPath
            Found = $caseInsensitiveMatch.FullName -replace [regex]::Escape((Get-Location).Path + '\'), ''
            Files = $allGraphics[$graphicPath]
        }
    } else {
        Write-Host "[MISSING] $graphicPath" -ForegroundColor Red
        $missing++
        $missingList += @{
            Path = $graphicPath
            Files = $allGraphics[$graphicPath]
        }
    }
    
    Write-Host "  Referenced in: $($allGraphics[$graphicPath] -join ', ')" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Total unique graphics: $($allGraphics.Count)"
Write-Host "  Found (exact match): $foundExact" -ForegroundColor Green
Write-Host "  Found (case mismatch): $foundCaseIssue" -ForegroundColor Magenta
Write-Host "  Found (JPG only): $foundJpgOnly" -ForegroundColor Yellow
Write-Host "  Missing: $missing" -ForegroundColor $(if ($missing -gt 0) { "Red" } else { "Green" })
Write-Host "========================================" -ForegroundColor Cyan

if ($caseIssueList.Count -gt 0) {
    Write-Host ""
    Write-Host "Files with case mismatches (need XML correction):" -ForegroundColor Magenta
    foreach ($item in $caseIssueList) {
        Write-Host "  Expected: $($item.Expected)" -ForegroundColor Yellow
        Write-Host "  Found:    $($item.Found)" -ForegroundColor Green
        Write-Host "  In files: $($item.Files -join ', ')" -ForegroundColor Gray
        Write-Host ""
    }
}

if ($missingList.Count -gt 0) {
    Write-Host ""
    Write-Host "Truly missing files:" -ForegroundColor Red
    foreach ($item in $missingList) {
        Write-Host "  - $($item.Path)" -ForegroundColor Red
        Write-Host "    Referenced in: $($item.Files -join ', ')" -ForegroundColor Gray
    }
}
