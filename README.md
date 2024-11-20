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

<br />
<br />

# Installation
1. Clone the repository to your local machine:
2. Add an alias to your bash or zsh profile

To automatically add this line to your bash/zsh you can run one of these scripts while in this repo folder:

### .zshrc file:
```
echo "\n\nalias unclog='$(pwd)/bin/unclog.sh'" >> ~/.zshrc
source ~/.zshrc
```

### .bashrc file:
```
echo "\n\nalias unclog='$(pwd)/bin/unclog.sh'" >> ~/.bashrc
source ~/.bashrc
```

# Testing it
You can immediately test it in this folder by running the `test_preview.sh` file:
```
./test_preview.sh
```
This will add some example `console.log` statements into a test file.

Then you can now run `unclog` in this repo and see the output:
```
unclog
```
