#!/usr/bin/env bash
# Copies the user's Plasma wallpaper to the image the greeter shows
# (auto_background in each theme's theme.conf).

target=/usr/share/sddm/wallpaper/image.png

# Only the user of the seat's active session copies: each copy wakes the path
# unit of every other logged-in user, and two different wallpapers would copy
# over each other without end.
session=$(loginctl show-seat seat0 --property=ActiveSession --value)
[[ -n $session && $(loginctl show-session "$session" --property=User --value) == "$UID" ]] || exit 0

image=$(grep -m1 -Po '(?<=^Image=).*' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc")
image=${image//[\";]/}
image=${image#file://}
# A wallpaper package holds one image per resolution; take the largest file.
if [[ -d $image ]]; then
    image=$(ls -S "$image"/contents/images/* 2>/dev/null | head -n1)
fi
# A plain color or a slideshow has no image.
[[ -f $image ]] || exit 0

# The path unit also watches the target, so an upgrade that restores the
# default image has it replaced again.
cmp -s "$image" "$target" || cp "$image" "$target"
