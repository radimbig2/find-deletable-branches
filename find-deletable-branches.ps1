<#
.SYNOPSIS
    Finds Git branches that have been merged into a specified main branch.

.DESCRIPTION
    This script lists all local or remote branches that have already been merged into the main branch
    (e.g., 'master' or 'main'). It displays the branch name, the date it was merged, and the
    merge commit ID.

    The output is sorted by merge date, with the most recent merges appearing first.
    The results are displayed on the screen and also saved to a file named 'deletable_branches_report.txt'.

    This helps identify branches that are safe to delete.

.NOTES
    - Make sure you are running this script from within a Git repository directory.
    - The script excludes the main branch itself and the currently checked-out branch from the list.
#>

# Set output encoding to UTF-8 to handle special characters in branch names
$OutputEncoding = [System.Text.Encoding]::UTF8

# --- CONFIGURATION ---
# Set the search mode. Options are:
# 'local'  - Finds LOCAL branches merged into your LOCAL 'master'.
# 'remote' - Finds REMOTE branches (origin/*) merged into 'origin/master'. This is useful for cleaning the remote repo.
$searchMode = "remote"

# Set the name of your primary branch (e.g., "master", "main")
$mainBranchName = "main"
# --- END CONFIGURATION ---

# Determine the full branch reference and search parameters based on the selected mode
if ($searchMode -eq "remote") {
    $mainBranch = "origin/$mainBranchName"
    $branchCommand = "git branch -r --merged $mainBranch"
    $branchPrefixToRemove = "origin/"
    $searchDescription = "REMOTE branches (origin/*) merged into '$mainBranch'"
} elseif ($searchMode -eq "local") {
    $mainBranch = $mainBranchName
    $branchCommand = "git branch --merged $mainBranch"
    $branchPrefixToRemove = ""
    $searchDescription = "LOCAL branches merged into '$mainBranch'"
} else {
    Write-Host "Error: Invalid searchMode. Please choose 'local' or 'remote'." -ForegroundColor Red
    exit 1
}

# Determine the full branch reference based on the selected scope
# Determine the full branch reference and search parameters based on the selected mode
if ($searchMode -eq "remote") {
    $mainBranch = "origin/$mainBranchName"
    $branchCommand = "git branch -r --merged $mainBranch"
    $branchPrefixToRemove = "origin/"
    $searchDescription = "REMOTE branches (origin/*) merged into '$mainBranch'"
} elseif ($searchMode -eq "local") {
    $mainBranch = $mainBranchName
    $branchCommand = "git branch --merged $mainBranch"
    $branchPrefixToRemove = ""
    $searchDescription = "LOCAL branches merged into '$mainBranch'"
} else {
    Write-Host "Error: Invalid searchMode. Please choose 'local' or 'remote'." -ForegroundColor Red
    exit 1
}

# Output file name
$outputFile = "deletable_branches_report.txt"

# Check if it's a git repository
git rev-parse --is-inside-work-tree | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: This is not a Git repository." -ForegroundColor Red
    exit 1
}

Write-Host "Searching for $searchDescription..."

# Fetch latest data from remote to ensure merge statuses are up-to-date
git fetch --prune

# Get all branches (local or remote) that have been merged into the main branch.
# The output is cleaned to remove whitespace and the '*' character for the current branch.
$mergedBranches = Invoke-Expression $branchCommand | ForEach-Object { $_.Trim().Replace("* ", "") }

$branchData = @()

foreach ($rawBranch in $mergedBranches) {
    # Skip the main branch itself and the HEAD pointer for remote searches
    if ($rawBranch -eq $mainBranch -or $rawBranch -like "*HEAD ->*") {
        continue
    }

    # Use the raw branch name for git commands, but a cleaned name for display
    $branchForGit = $rawBranch
    $displayBranchName = $rawBranch.Replace($branchPrefixToRemove, "")

    # Skip the main branch again after cleaning the name
    if ($displayBranchName -eq $mainBranchName) {
        continue
    }

    try {
        # Get the commit hash of the tip of the branch, redirecting stderr to null
        $tipCommit = git rev-parse $branchForGit 2>$null

        # Get the author of the last commit in the branch
        $author = git log -1 --format="%an" $branchForGit 2>$null

        # Find the merge commit in the main branch's history where the branch's tip is the second parent.
        # This is a reliable way to find the exact merge point.
        $mergeCommitHash = git rev-list --merges --parents $mainBranch | Where-Object { ($_ -split ' ')[2] -eq $tipCommit } | Select-Object -First 1 | ForEach-Object { ($_ -split ' ')[0] }

        if (-not [string]::IsNullOrEmpty($mergeCommitHash)) {
            # If a merge commit is found, get its date and short hash
            $mergeInfo = git show -s --format="%cI;%h" $mergeCommitHash
            $mergeDate = ($mergeInfo -split ';')[0]
            $commitId = ($mergeInfo -split ';')[1]

            $branchData += [PSCustomObject]@{
                MergeDate  = [datetime]$mergeDate
                BranchName = $displayBranchName
                CommitID   = $commitId
                Author     = $author
            }
        }
        # Note: This script intentionally ignores fast-forwarded or squashed branches
        # as finding their true "merge date" into the main branch is not straightforward.
    } catch {
        Write-Warning "Could not process branch '$displayBranchName'. It might have been deleted or have other issues."
    }
}

# Sort the collected data by author, then by merge date in descending order
$sortedData = $branchData | Sort-Object -Property Author, @{Expression={$_.MergeDate}; Descending=$true}

if ($sortedData.Count -eq 0) {
    Write-Host "No merged branches found that match the criteria."
    return
}

# Prepare the report for display and file output
$reportHeader = "--- Branches Merged into '$mainBranch' (Mode: $searchMode) ---"

# Display the report in the console
Write-Host "`n$reportHeader"

# Initialize the output file
"Report for branches merged into '$mainBranch' (Mode: $searchMode) as of $(Get-Date)" | Set-Content -Path $outputFile
"---" | Add-Content -Path $outputFile

# Group by author and display
$groupedData = $sortedData | Group-Object -Property Author

foreach ($authorGroup in $groupedData) {
    $authorHeader = "`n=== Author: $($authorGroup.Name) ($($authorGroup.Count) branches) ==="

    # Display to console
    Write-Host $authorHeader -ForegroundColor Cyan
    $authorGroup.Group | Format-Table -Property @{Expression={$_.MergeDate.ToString('yyyy-MM-dd')}; Label="Merge Date"}, BranchName, CommitID -AutoSize | Out-String | Write-Host

    # Save to file
    $authorHeader | Add-Content -Path $outputFile
    $authorGroup.Group | Format-Table -Property @{Expression={$_.MergeDate.ToString('yyyy-MM-dd')}; Label="Merge Date"}, BranchName, CommitID -AutoSize | Out-String | Add-Content -Path $outputFile
}

$reportFooter = "`n-----------------------------------------------------------"
Write-Host $reportFooter

$reportFooter | Add-Content -Path $outputFile

Write-Host "`nReport saved to '$outputFile'"