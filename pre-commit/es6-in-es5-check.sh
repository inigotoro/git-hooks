#!/usr/bin/env sh

# Initial code obtained from https://stackoverflow.com/questions/32356457/git-pre-commit-hook-to-find-text-in-files

# List of ES6 terms to looks for. Add here any future one
DISALLOWED="const let =>"

# Get the list of all non ES6 javascript modified files
CHANGES="$(git diff --diff-filter=ACMR --name-only HEAD | grep '\.js' | grep -v '/es6/')"

# If no changes in ES5 files, skip the rest of checks
if [ -z "$CHANGES" ]; then
    echo "_ Skipping ES6 in ES5 checks - no changes in ES5 .js files"
    exit 0
fi

echo ""
echo "┌───────────────────────────────────────┐"
echo "│ Checking for ES6 code in ES5 files... │"
echo "└───────────────────────────────────────┘"
echo ""

# Loop list of modified files
for FILE in ${CHANGES}; do
    # Loop list of banned ES6 words
    for WORD in $DISALLOWED
    do
        if egrep -w $WORD $FILE ; then
            echo -e -n "⚠  \e[33mWARNING: \e[0mpotential ES6 expression (\"${WORD}\") in file: ${FILE}. Continue?? (y/N/skip-all) "
            read WARNINGINPUT </dev/tty
            if [ "${WARNINGINPUT}" == "y" ] || [ "${WARNINGINPUT}" == "Y" ]; then
                echo ""
                continue
            elif [ "${WARNINGINPUT}" == "skip-all" ]; then
                echo "_ 💀💀  Manually skipping ES6 in ES5 checks"
                exit 0
            else
                echo "🛑  Unauthorised ES6 expression found. Commit prevented 👍"
                exit 1
            fi
        fi
    done
done
echo "    ──────────────────────────────────────────────────────"
echo " 🚀  ES6 in ES5 Checks finished. Proceeding with commit... 🚀"
echo ""