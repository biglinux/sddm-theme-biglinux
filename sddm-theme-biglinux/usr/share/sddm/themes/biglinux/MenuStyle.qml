import QtQuick 2.2

import org.kde.plasma.core 2.0 as PlasmaCore

import QtQuick.Controls.Styles 1.4 as QQCS
import QtQuick.Controls 1.3 as QQC

QQCS.MenuStyle {
                frame: Rectangle {
                    id: selectBackground
                    color:"#000"
                    opacity: 0.5
                }
                itemDelegate.label: QQC.Label {
                    height: contentHeight * 2
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color:"#fff"
                    font.pointSize: 12
                    text: styleData.text
                }
                itemDelegate.background: Rectangle {
                    visible: styleData.selected
                    color: PlasmaCore.ColorScope.highlightColor
                    radius: 15
                }
}
