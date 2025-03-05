#!/bin/bash
# Purpose: Create a new TypeScript + Bun script repo
# Usage: ./setup.sh <script-name>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <script-name>"
    exit 1
fi

SCRIPT_NAME="$1"

# Customize
sed -i "s/\[script-name\]/$SCRIPT_NAME/g" src/index.ts flake.nix package.json
sed -i "s/\[Script Name\]/$SCRIPT_NAME/g" README.md
sed -i "s/\[script-name\]/$SCRIPT_NAME/g" README.md
sed -i "s/\[One-line description\]/[Describe $SCRIPT_NAME here]/g" README.md package.json
sed -i "s/\[args\]/[specific args]/g" README.md

# Generate bun.lockb
nix develop -c bun install

# Initialize git repo
git init
git add .
git commit -m "Initial commit for $SCRIPT_NAME"
