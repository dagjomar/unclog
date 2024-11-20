#!/bin/bash

# Console Log Finder - Finds console log lines that you have added
# ----------------------------------------
# A developer utility script that helps find console logging statements
# in your uncommitted changes (staged, unstaged, and untracked files).
#
# Why is this useful?
# - Helps clean up debug statements before committing
# - Shows exact file locations and line numbers
# - Finds all types of console methods (log, error, warn, etc.)
# - Prevents accidental commits of debug logging
# - helps you located the exact location of a particular console.log statement
#   and modify it while debugging.
# - Depending on your IDE/Terminal setup, you can click on the
#   file path and it will open the file in your editor at the correct line number
#

REPO_ROOT=$(git rev-parse --show-toplevel)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

FIX_MODE=false
DRY_RUN=false

for arg in "$@"; do
    if [ "$arg" = "--fix" ]; then
        FIX_MODE=true
    fi
    if [ "$arg" = "--dry" ]; then
        DRY_RUN=true
    fi
done

# Define console methods to search for
PATTERNS=(
    'console.log\('
    'console.error\('
    'console.warn\('
    'console.debug\('
    'console.info\('
    'window.alert\('
)

# Near the top, replace declare -A with temp file creation
TEMP_FILE=$(mktemp)
trap 'rm -f $TEMP_FILE' EXIT

# Convert patterns array to grep pattern
GREP_PATTERN=$(IFS='|'; echo "${PATTERNS[*]}")

# Function to print a formatted console match
print_match() {
    local file=$1
    local linenum=$2
    local content=$3

    if [ -z "$file" ] || [ -z "$linenum" ] || [ -z "$content" ]; then
        echo "Error: Missing required parameters in print_match"
        return 1
    fi

    echo -e "  • ${YELLOW}$file:$linenum${NC}"
    echo -e "    $content"

    # Store as file:linenum in temp file
    # echo "$file:$linenum" >> "$TEMP_FILE"
    # Store absolute path
    echo "${REPO_ROOT}/${file}:${linenum}" >> "$TEMP_FILE"
}

remove_console_logs() {
    if [ "$FIX_MODE" = true ]; then
        # Sort unique files
        for file in $(cut -d: -f1 "$TEMP_FILE" | sort -u); do
            echo -e "\n${GREEN}Removing console.logs from $file...${NC}"
            # Get and sort line numbers in descending order
            grep "^$file:" "$TEMP_FILE" | cut -d: -f2 | sort -nr | while read -r line; do
                if [ "$DRY_RUN" = true ]; then
                    # Remove the line
                    echo "Would remove line $line"
                else
                    sed -i.bak "${line}d" "$file"
                fi
            done

            if [ "$DRY_RUN" = false ]; then
                rm "${file}.bak"
            fi
        done
    fi
}

# Function to process git diff output
process_diff() {
    local diff_type=$1
    local current_file=""
    local current_line=0
    local in_hunk=false

    git diff $diff_type --unified=0 | while IFS= read -r line; do
        if [[ $line =~ ^diff\ --git\ a/(.*)\ b/(.*) ]]; then
            current_file="${BASH_REMATCH[2]}"
            in_hunk=false
        elif [[ $line =~ ^@@\ -[0-9]+(,[0-9]+)?\ \+([0-9]+)(,[0-9]+)?\ @@.* ]]; then
            # Extract the actual line number from the @@ marker
            current_line=$(echo "${BASH_REMATCH[2]}" | sed 's/+//')
            in_hunk=true
        elif $in_hunk; then
            if [[ $line =~ ^[\+] ]] && [[ $line =~ $GREP_PATTERN ]]; then
                content=$(echo "$line" | sed 's/^[+]//')
                if [[ -n "$current_file" ]]; then
                    print_match "$current_file" "$current_line" "$content"
                fi
            fi
            # Count all lines in the hunk except removal lines
            if [[ ! $line =~ ^\- ]]; then
                ((current_line++))
            fi
        fi
    done
}


# Check staged changes
echo -e "${GREEN}Checking staged changes...${NC}"
process_diff "--cached"

# Check unstaged changes
echo -e "${BLUE}Checking unstaged changes...${NC}"
process_diff ""

# Check untracked files
echo -e "${RED}Checking untracked files...${NC}"
git ls-files --others --exclude-standard | while read -r file; do
    if [ -f "$file" ]; then
        while IFS=: read -r line_num content; do
            # Only process lines that contain our patterns
            if [[ $content =~ $GREP_PATTERN ]]; then
                print_match "$file" "$line_num" "$(echo "$content" | sed -e 's/^[[:space:]]*//')"
            fi
        done < <(nl -ba "$file" | sed 's/[[:space:]]*\([0-9]*\)[[:space:]]*/\1:/')
    fi
done

# Check if we found any changes
if [ -z "$(git diff)" ] && [ -z "$(git diff --cached)" ] && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo "No console statements found in any changes."
fi

if [ "$FIX_MODE" = true ]; then
    remove_console_logs
fi