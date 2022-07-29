#!/usr/bin/env sh

# Make a vendor directory
echo "[info] making vendor directory"
mkdir ${HOME}/vendor

# Install LazyGit
echo "[info] installing lazygit"
cd ${HOME}/vendor
git clone https://github.com/jesseduffield/lazygit.git
cd lazygit
go install
cd ${HOME}

# Aliases
alias cls='clear'
alias g='git'

# Complete!
echo "[info] succcess!"
