#!/usr/bin/env bash

cp "$(grep -m1 -Po "(?<=^Image=).*" "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" | tr -d '"' | tr -d ';')" /usr/share/sddm/wallpaper/image.png
