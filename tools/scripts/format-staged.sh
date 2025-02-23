#!/bin/bash

# Get list of staged Swift files
staged_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$')

# If no Swift files are staged, exit
if [ -z "$staged_files" ]; then
  exit 0
fi

# Run swift-format on all staged files at once
echo "Running swift-format on staged files..."
swift-format format --in-place $staged_files

# Re-add all formatted files to the staging area
git add $staged_files

echo "swift-format completed."