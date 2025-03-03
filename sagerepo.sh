#!/usr/bin/env bash

APT_REPO_DIR="/opt/sagerepo"
GIT_REPO_URI="https://github.com/keyboardsage/sagedebs"
SOURCES_LIST="/etc/apt/sources.list"

# Sanity check
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run by root (sudo)' >&2
    exit 1
fi

# Handle the repo directory
if [ -d "$APT_REPO_DIR" ]; then
    echo "[*] Cleaning up the existing repo directory"
    cd "$APT_REPO_DIR"
    if [ -d ".git" ]; then
        git reset --hard  # Discard uncommitted changes
        git clean -fdx    # Remove untracked files and directories
        git pull "$GIT_REPO_URI"
    else
        echo "[*] Directory exists but is not a Git repository. Recreating it."
        rm -rf "$APT_REPO_DIR"
        mkdir -p "$APT_REPO_DIR"
        cd "$APT_REPO_DIR"
        git clone "$GIT_REPO_URI" .
    fi
else
    echo "[*] Creating the repo directory"
    mkdir -p "$APT_REPO_DIR"
    cd "$APT_REPO_DIR"
    git clone "$GIT_REPO_URI" .
fi

# Download additional .deb files
echo "[*] Downloading additional .deb files"
wget "https://downloads.slack-edge.com/releases/linux/4.31.155/prod/x64/slack-desktop-4.31.155-amd64.deb"
wget "https://github.com/PowerShell/PowerShell/releases/download/v7.1.4/powershell_7.1.4-1.ubuntu.20.04_amd64.deb"
wget "https://az764295.vo.msecnd.net/stable/d037ac076cee195194f93ce6fe2bdfe2969cc82d/code_1.84.0-1698839401_amd64.deb"
wget "https://dl.audiorelay.net/setups/linux/audiorelay-0.27.5.deb"
wget "https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb"
wget "https://www.expressvpn.works/clients/linux/expressvpn_3.58.0.2-1_amd64.deb"
wget "https://dl.discordapp.net/apps/linux/0.0.84/discord-0.0.84.deb"
wget "https://download3.omnissa.com/software/CART25FQ2_LIN64_DEBPKG_2406/VMware-Horizon-Client-2406-8.13.0-9995429239.x64.deb"

# Create a Release/Packages file that apt can read
echo "[*] Creating the Release file"
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz

# Add the new source of debs to the sources.list if needed
echo "[*] Adding the repo to the system (if not already present)"
grep -qxF 'deb [trusted=yes] file://'"$APT_REPO_DIR"' ./' $SOURCES_LIST || echo 'deb [trusted=yes] file://'"$APT_REPO_DIR"' ./' >> $SOURCES_LIST

# Do an apt update to use the repo
echo "[*] Updating apt to utilize the new repo"
apt-get update

# Remove the script/readme etc. files
echo "[*] Removing unnecessary files from the new apt repo"
THIS_SCRIPT=$(basename "$0")
rm "$APT_REPO_DIR/$THIS_SCRIPT"
rm "$APT_REPO_DIR/README.md"
