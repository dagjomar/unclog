# UnClog
## Remove unwanted console.logs before committing

### Problem Statement
As a frontend developer, I often add console.logs to debug problems. After fixing the bug, these console.logs remain scattered throughout the project. Manually removing them before committing can be tedious and error-prone.

UnClog helps automate this cleanup process.

### Overview
UnClog is a script that finds and optionally removes console logging statements in your uncommitted changes (staged, unstaged, and untracked files). This tool is useful for cleaning up debug statements before committing your code.

### Features
- Finds all types of console methods (log, error, warn, debug, info) and window alerts.
- Shows exact file locations and line numbers.
- Prevents accidental commits of debug logging.
- Helps you locate specific console.log statements for modification.
- Depending on your IDE/Terminal setup, you can click on the file path to open the file at the correct line number.

### Usage
To use the script, navigate to your repository root and run the script with the desired options.

#### Options
- `--fix`: Automatically remove found console logs.
- `--dry`: Perform a dry run without making any changes.

#### Examples
TODO: Add examples