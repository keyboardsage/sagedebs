#!/usr/bin/env bash
# Updates out-of-date debs in the repo, only updates the Discord deb for now

LatestDeb=`curl -s 'https://discord.com/api/download?platform=linux&format=deb'   | grep -o 'discord-[0-9\.]*\.deb'   | sed 's/discord-\(.*\)\.deb/\1/' | head -n 1`
CurrentDeb=`apt version discord`

if dpkg --compare-versions "$LatestDeb" gt "$CurrentDeb"; then
  echo "must update"
else
  echo "already up-to-date"
fi

sed -i "s|apps/linux/[0-9\.]*/discord-[0-9\.]*\.deb|apps/linux/$LatestDeb/discord-$LatestDeb.deb|" sagerepo.sh

