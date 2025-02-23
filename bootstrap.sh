#!/bin/bash

# Exit on any error
set -e

# Path to the pre-commit script
PRE_COMMIT_SCRIPT="tools/scripts/pre-commit.sh"
HOOKS_DIR=".git/hooks"
PRE_COMMIT_HOOK="$HOOKS_DIR/pre-commit"

# Check if pre-commit.sh exists
if [ ! -f "$PRE_COMMIT_SCRIPT" ]; then
  echo "Error: $PRE_COMMIT_SCRIPT not found!"
  exit 1
fi

# Ensure hooks directory exists
if [ ! -d "$HOOKS_DIR" ]; then
  echo "Error: $HOOKS_DIR does not exist. Is this a git repository?"
  exit 1
fi

# Copy pre-commit.sh to the hooks directory
cp "$PRE_COMMIT_SCRIPT" "$PRE_COMMIT_HOOK"

# Make sure the pre-commit hook is executable
chmod +x "$PRE_COMMIT_HOOK"

echo "✅ Pre-commit hook installed successfully!"