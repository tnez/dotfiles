#!/bin/bash

# Dependency: requires trash
# Install with Homebrew: `brew install trash`

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clean Desktop
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🗑️
# @raycast.packageName Desktop Cleaner

trash $HOME/Desktop/*
