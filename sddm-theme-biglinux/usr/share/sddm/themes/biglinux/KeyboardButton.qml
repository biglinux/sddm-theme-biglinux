import QtQuick 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // Because PC3 ToolButton can't take a menu

import QtQuick.Controls 1.3 as QQC

Item{
    anchors {
        top: parent.top
        topMargin: units.largeSpacing
        left: parent.left
        leftMargin: units.largeSpacing
    }

    Image{
        source: "/usr/share/sddm/themes/biglinux/components/artwork/input-keyboard-virtual.svg" 
        MouseArea {
            anchors.fill: parent
            onClicked: inputPanel.showHide() 
            hoverEnabled: true
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
        
    }

    visible: inputPanel.status == Loader.Ready
    }
