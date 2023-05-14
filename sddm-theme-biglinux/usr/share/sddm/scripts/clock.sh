#!/bin/bash

#Detect language of quote
if [ "$(grep LANG= /etc/locale.conf | grep pt)" != "" ]
then
    echo "$(/usr/bin/fortune biglinux-ptbr | sed "s|\"|¨|g;s|'|¨|g")" > /tmp/biglinux_quote
else
    if [ "$(grep LANG= /etc/locale.conf | grep es)" != "" ]
    then
        echo "$(/usr/bin/fortune biglinux-es | sed "s|\"|¨|g;s|'|¨|g")" > /tmp/biglinux_quote
    else
        echo "$(/usr/bin/fortune biglinux-en | sed "s|\"|¨|g;s|'|¨|g")" > /tmp/biglinux_quote
    fi
fi

cat << EOF > /usr/share/sddm/themes/biglinux/components/PhrasesModel.qml

/*
 *   Copyright 2023 Douglas Guimarães <dg2003gh@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import org.kde.plasma.components 3.0 as PlasmaComponents3
import QtQuick.Layouts 1.1

PlasmaComponents3.Label {
            id: phrasesLabel
            
            text: "$(cat /tmp/biglinux_quote)"
            font.pointSize: root.fontSize
            color: "#999"
            Layout.maximumWidth: units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.italic: true
        }

EOF
