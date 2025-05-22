# Get-FilteredFiles.ps1

function Get-FilteredFileItems {
    # Function to get file items based on various filter criteria.
    param(
        [string]$RootPath,
        [string[]]$IncludeFolders = @(),
        [string[]]$ExcludeFolders = @(),
        [string[]]$IncludeExtensions = @(), 
        [string[]]$ExcludeExtensions = @(), 
        [long]$MinSize = -1, 
        [long]$MaxSize = -1  
    )

    Write-Host "DEBUG: Get-FilteredFileItems called." -ForegroundColor Yellow
    Write-Host "DEBUG: RootPath: $RootPath" -ForegroundColor Yellow
    Write-Host "DEBUG: IncludeFolders: $($IncludeFolders -join ', ')" -ForegroundColor Yellow
    Write-Host "DEBUG: ExcludeFolders: $($ExcludeFolders -join ', ')" -ForegroundColor Yellow
    Write-Host "DEBUG: IncludeExtensions: $($IncludeExtensions -join ', ')" -ForegroundColor Cyan # Critical for this issue
    Write-Host "DEBUG: ExcludeExtensions: $($ExcludeExtensions -join ', ')" -ForegroundColor Yellow
    Write-Host "DEBUG: MinSize: $MinSize, MaxSize: $MaxSize" -ForegroundColor Yellow

    $allFiles = Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue
    Write-Host "DEBUG: Found $($allFiles.Count) total files initially in $RootPath." -ForegroundColor Yellow

    # Using a generic list for adding items
    $filteredFileResult = New-Object System.Collections.Generic.List[System.IO.FileInfo]

    foreach ($file in $allFiles) {
        $currentFileNameForDebug = $file.Name
        $currentFileExtForDebug = $file.Extension.ToLowerInvariant()
        # Write-Host "DEBUG: ----- Processing File: '$($file.FullName)' (Ext: '$currentFileExtForDebug') -----" -ForegroundColor Magenta
        
        $shouldProcess = $true
        [string]$reasonForFiltering = "Passed initial check."

        # Folder Include Filter
        if ($IncludeFolders.Count -gt 0) {
            $matchIncludeFolder = $false
            foreach ($incFolder in $IncludeFolders) {
                $fullIncFolderPath = Join-Path $RootPath $incFolder
                $pattern = if ($incFolder.EndsWith('\*') -or $incFolder.EndsWith('/*')) { $fullIncFolderPath.Replace('\*','\*').Replace('/*','\*') } else { $fullIncFolderPath + '\*' }
                if ($file.DirectoryName -like $pattern -or $file.DirectoryName -eq $fullIncFolderPath) {
                    $matchIncludeFolder = $true; break
                }
            }
            if (-not $matchIncludeFolder) {
                $shouldProcess = $false; $reasonForFiltering = "Did not match IncludeFolders: '$($IncludeFolders -join ", ")'"
            }
        }

        # Folder Exclude Filter
        if ($shouldProcess -and $ExcludeFolders.Count -gt 0) {
            foreach ($excFolder in $ExcludeFolders) {
                $fullExcFolderPath = Join-Path $RootPath $excFolder
                $pattern = if ($excFolder.EndsWith('\*') -or $excFolder.EndsWith('/*')) { $fullExcFolderPath.Replace('\*','\*').Replace('/*','\*') } else { $fullExcFolderPath + '\*' }
                if ($file.DirectoryName -like $pattern -or $file.DirectoryName -eq $fullExcFolderPath) {
                    $shouldProcess = $false; $reasonForFiltering = "Matched ExcludeFolders: '$excFolder'"; break
                }
            }
        }

        # Extension Include Filter
        if ($shouldProcess -and $IncludeExtensions.Count -gt 0) {
            # Write-Host "DEBUG:   ExtIncl Check for '$currentFileNameForDebug'. FileExt: '$currentFileExtForDebug'. TargetExts: '$($IncludeExtensions -join '; ')'" -ForegroundColor Cyan
            if (-not ($IncludeExtensions -contains $currentFileExtForDebug)) {
                $shouldProcess = $false
                $reasonForFiltering = "Ext '$currentFileExtForDebug' NOT IN IncludeExtensions '$($IncludeExtensions -join '; ')'."
                # Write-Host "DEBUG:   '$currentFileNameForDebug' FAILED IncludeExtensions. Reason: $reasonForFiltering" -ForegroundColor Red
            } else {
                # Write-Host "DEBUG:   '$currentFileNameForDebug' PASSED IncludeExtensions." -ForegroundColor Green
            }
        }

        # Extension Exclude Filter
        if ($shouldProcess -and $ExcludeExtensions.Count -gt 0) {
            # Write-Host "DEBUG:   ExtExcl Check for '$currentFileNameForDebug'. FileExt: '$currentFileExtForDebug'. TargetExts: '$($ExcludeExtensions -join '; ')'" -ForegroundColor Cyan
            if ($ExcludeExtensions -contains $currentFileExtForDebug) {
                $shouldProcess = $false
                $reasonForFiltering = "Ext '$currentFileExtForDebug' IN ExcludeExtensions '$($ExcludeExtensions -join '; ')'."
                # Write-Host "DEBUG:   '$currentFileNameForDebug' FAILED ExcludeExtensions. Reason: $reasonForFiltering" -ForegroundColor Red
            } else {
                # Write-Host "DEBUG:   '$currentFileNameForDebug' PASSED ExcludeExtensions." -ForegroundColor Green
            }
        }

        # Min Size Filter
        if ($shouldProcess -and $MinSize -ge 0) {
            if ($file.Length -lt $MinSize) {
                $shouldProcess = $false; $reasonForFiltering = "Size $($file.Length) is less than MinSize $MinSize."
            }
        }

        # Max Size Filter
        if ($shouldProcess -and $MaxSize -ge 0) {
            if ($file.Length -gt $MaxSize) {
                $shouldProcess = $false; $reasonForFiltering = "Size $($file.Length) is greater than MaxSize $MaxSize."
            }
        }

        if ($shouldProcess) {
            # Write-Host "DEBUG: File '$($file.FullName)' PASSED ALL FILTERS." -ForegroundColor Green
            $filteredFileResult.Add($file)
        } else {
            # Write-Host "DEBUG: File '$($file.FullName)' FILTERED OUT. Final Reason: $reasonForFiltering" -ForegroundColor Red
        }
    }
    Write-Host "DEBUG: Get-FilteredFileItems returning $($filteredFileResult.Count) files." -ForegroundColor Yellow
    return $filteredFileResult
}