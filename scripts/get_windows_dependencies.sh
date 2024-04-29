#!/usr/bin/env bash

set -e

mkdir deps
cd deps

MPV_SHA1="44dbdf260b3bb2f2db70b0fa3e22d1138714dd75"
MPV_MD5="9844e3279dca2cd946388abe7742498f"
FFMPEG_SHA256="2b4eaf0959f58b154d236c034a3daf3a1e40f1fec815d6644391bbffe841f828"

curl -L -o mpv.7z https://sourceforge.net/projects/mpv-player-windows/files/release/mpv-0.38.0-x86_64.7z/download
curl -L -o ffmpeg.7z https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z

[[ "$MPV_SHA1" == "$(sha1sum mpv.7z | cut -d ' ' -f 1)" ]] || ( echo "Could not verify mpv.7z"; exit 1 )
[[ "$MPV_MD5" == "$(md5sum mpv.7z | cut -d ' ' -f 1)" ]] || ( echo "Could not verify mpv.7z"; exit 1 )
[[ "$FFMPEG_SHA256" == "$(sha256sum ffmpeg.7z | cut -d ' ' -f 1)" ]] || ( echo "Could not verify ffmpeg.7z"; exit 1 )

echo "Successfully downloaded dependencies"
