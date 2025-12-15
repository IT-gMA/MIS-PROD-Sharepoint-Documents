#!/bin/bash
# Specify the target directory at the root of the project
TARGET_DIR="."
cd "$TARGET_DIR" || exit

# Run the tree command with the specified options and output to project_structure.txt
tree -I ".git*|node_modules|package.json|package-lock.json|tsconfig.json|*project_structure*" --prune > project_structure.txt

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Project structure saved to project_structure.txt"
else
    echo "Failed to generate project structure."
fi
