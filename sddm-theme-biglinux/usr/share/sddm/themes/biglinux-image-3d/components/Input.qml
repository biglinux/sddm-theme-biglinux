import QtQuick 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.4

TextField {
    placeholderTextColor: config.color
    palette.text: config.color
    color: config.color
    font.pointSize: config.fontSize
    font.family: config.font
    width: parent.width
    leftPadding: 10
    background: Rectangle {
        color: "#303030"
        radius: 12
        width: parent.width + 2
        opacity: 0.8
        border.width: 1
        border.color: "#b1b1b1"
        anchors.fill: parent
    }
}
