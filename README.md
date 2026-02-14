# git-merged

🔍 Find Git branches that have been merged into your main/production branch.

A simple, fast CLI tool to identify branches that are safe to delete because they've already been merged into your target branch.

## Installation

Install globally via npm:

```bash
npm install -g git-merged
```

## Usage

### Basic Usage

```bash
# Find remote branches merged into origin/main
git-merged

# Find branches merged into production
git-merged production

# Find branches merged into develop
git-merged develop
```

### Options

```bash
git-merged [branch-name] [options]
```

**Arguments:**
- `branch-name` - Target branch to check merges into (default: `main`)

**Options:**
- `-l, --local` - Search local branches instead of remote
- `-r, --remote` - Search remote branches (default)
- `-n, --no-file` - Don't save to file, only display in console
- `-o, --output PATH` - Custom output file path
- `-h, --help` - Show help message

### Examples

#### Find remote branches merged into origin/main
```bash
git-merged
```

#### Find local branches merged into develop
```bash
git-merged develop --local
```

#### Display results without saving to file
```bash
git-merged main --no-file
```

#### Save to custom location
```bash
git-merged main --output ~/reports/merged-branches.txt
```

#### Combined options
```bash
git-merged production --local --output ./report.txt
```

## Output

The tool displays results grouped by author, showing:
- **Merge Date** - When the branch was merged
- **Branch Name** - Name of the merged branch
- **Commit ID** - Short hash of the merge commit
- **Author** - Who created the branch

Example output:
```
--- Branches Merged into 'origin/main' (Mode: remote) ---

=== Author: John Doe ===
Merge Date    Branch Name                      Commit ID
----------    -----------                      ---------
2024-02-10    feature/user-authentication      a1b2c3d
2024-02-08    bugfix/login-error              e4f5g6h

=== Author: Jane Smith ===
Merge Date    Branch Name                      Commit ID
----------    -----------                      ---------
2024-02-12    feature/dashboard-redesign       i7j8k9l
```

## Requirements

- **Git** must be installed and available in PATH
- Must be run from within a Git repository
- For remote mode, requires access to `origin` remote

## How It Works

The tool:
1. Fetches the latest data from remote (if in remote mode)
2. Lists all branches merged into the target branch
3. Identifies actual merge commits (excludes fast-forwards and squashes)
4. Extracts merge date, author, and commit information
5. Groups results by author and sorts by date

## Notes

- The tool only identifies branches merged via explicit merge commits
- Fast-forwarded or squashed branches are excluded (their "merge date" cannot be reliably determined)
- By default, results are saved to `deletable_branches_report.txt` in the current directory

## Development

### PowerShell Version

The original PowerShell version is still available as `find-deletable-branches.ps1` for Windows users who prefer PowerShell.

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Issues

Found a bug or have a feature request? Please open an issue on GitHub.
