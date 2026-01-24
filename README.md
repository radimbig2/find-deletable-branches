# find-deletable-branches

This script lists all local or remote branches that have already been merged into the main branch (e.g., 'master' or 'main'). It displays the branch name, the date it was merged, and the merge commit ID.
The output is sorted by merge date, with the most recent merges appearing first.
The results are displayed on the screen and also saved to a file named 'deletable_branches_report.txt'.
This helps identify branches that are safe to delete.

## New Features

### Interactive Branch Deletion
After displaying the report of merged branches grouped by author, the script now offers an **interactive menu** that allows you to:

1. **Select an author group** - View all branches by a specific author that are safe to delete
2. **Choose deletion mode**:
   - Delete from **REMOTE only** (origin)
   - Delete from **LOCAL only**
   - Delete from **BOTH** (local & remote)
3. **Confirm deletion** - Final confirmation required (type "YES") before any branches are deleted
4. **View deletion summary** - See how many branches were successfully deleted and if any failures occurred

This makes it easy to clean up branches incrementally by author, with full control over what gets deleted and where.

# How to use?
1. Git must be installed on your computer
2. Copy the script to the folder with the repository!
3. Edit the variables in the script 'searchMode' (default remote), 'mainBranchName' (default master), possibly 'outputFile' (default deletable_branches_report.txt). See the description in the script comment.
4. The script is executed in Windows PowerShell and must be in the folder with the repository.
Run command
```
powershell -ExecutionPolicy Bypass -File .\find-deletable-branches.ps1
```
The result will be saved to the file specified in the outputFile variable

5. After viewing the report, use the interactive menu to select and delete branches:
   - Choose an author by number
   - Review the branches to be deleted
   - Select deletion mode (remote/local/both)
   - Confirm with "YES" to proceed
   - Type "0" or press Enter to exit at any time

## Safety Features
- Requires explicit confirmation ("YES") before deleting any branches
- Shows detailed summary of successful and failed deletions
- Allows you to review branches before deletion
- Can delete from remote, local, or both repositories independently
