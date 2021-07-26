#!/usr/bin/env bash

APT_REPO_DIR="/opt/sagerepo"
GIT_REPO_URI="https://github.com/keyboardsage/sagedebs"
SOURCES_LIST="/etc/apt/sources.list"

# Sanity check
if [ "$(id -u)" -ne 0 ]; then
	echo 'This script must be run by root (sudo)' >&2
	exit 1
fi

# Create a directory for custom deb files
echo "[*] Creating the repo directory"
mkdir -p "$APT_REPO_DIR"

# Clone the git repo in that directory
echo "[*] Cloning the repo of debs"
if [ "$(ls -A $APT_REPO_DIR/)" ]; then
	cd "$APT_REPO_DIR"
	git pull "$GIT_REPO_URI"
else
	cd "$APT_REPO_DIR"
	git clone "$GIT_REPO_URI" .
fi

# Create a Release/Packages file that apt can read
echo "[*] Creating the Release file"
#dpkg-scanpackages . /dev/null > Release
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz

# Add the new source of debs to the sources.lst if needed
echo "[*] Adding the repo to the system (if not already present)"
grep -qxF 'deb [trusted=yes] file://'"$APT_REPO_DIR"' ./' $SOURCES_LIST || echo 'deb [trusted=yes] file://'"$APT_REPO_DIR"' ./' >> $SOURCES_LIST

# Do an apt update to use the repo
echo "[*] Updating apt to utilize the new repo"
apt-get update

# Remove the script/readme etc. files
echo "[*] Removing unnecessary files from the new apt repo"
THIS_SCRIPT=`basename "$0"`
rm "$APT_REPO_DIR/""$THIS_SCRIPT"
rm "$APT_REPO_DIR/""README.md"
