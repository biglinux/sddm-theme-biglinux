/*
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
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

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasma5support 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami
import org.kde.breeze.components
import "components"

Item {
    id: root

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    width: Screen.width
    height: Screen.height

    property string notificationMessage

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    PlasmaCore.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    Rectangle {
        id: wallpaper
        width: root.width
        height: root.height
        // Gradient background
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#020024" }  // Dark blue at the top
            GradientStop { position: 1.0; color: "#1e1e1e" }  // Lighter blue at the bottom
        }

        Canvas {
            id: canvas
            anchors.fill: parent
            property var stars: []

            onPaint: {
                var ctx = canvas.getContext("2d");
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                
                // Draw stars
                for (var i = 0; i < stars.length; i++) {
                    var star = stars[i];
                    ctx.beginPath();
                    ctx.arc(star.x, star.y, star.size, 0, 2 * Math.PI, false);
                    ctx.fillStyle = "rgba(" + star.color.r + ", " + star.color.g + ", " + star.color.b + ", " + star.opacity + ")";
                    ctx.fill();
                }
            }

            function createStar() {
                var colors = [
                    {r: 255, g: 255, b: 255}, // White
                    {r: 255, g: 255, b: 200}, // Yellowish
                    {r: 255, g: 200, b: 200}, // Reddish
                    {r: 200, g: 255, b: 200}, // Greenish
                    {r: 200, g: 200, b: 255}  // Bluish
                ];
                var color = colors[Math.floor(Math.random() * colors.length)];
                return {
                    x: Math.random() * canvas.width,
                    y: Math.random() * canvas.height,
                    size: Math.random() * 2 + 1, // Small stars
                    opacity: Math.random(),
                    twinkleSpeed: Math.random() * 0.02 + 0.01, // Speed of twinkling
                    color: color
                };
            }

            Component.onCompleted: {
                for (var i = 0; i < 150; i++) { // Adjust the number of stars to balance performance
                    stars.push(createStar());
                }
                canvas.requestPaint();
            }

            Timer {
                interval: 70 // Increase interval to reduce CPU usage
                running: true
                repeat: true
                onTriggered: {
                    for (var i = 0; i < canvas.stars.length; i++) {
                        var star = canvas.stars[i];
                        star.opacity += star.twinkleSpeed;
                        if (star.opacity <= 0 || star.opacity >= 1) {
                            star.twinkleSpeed = -star.twinkleSpeed; // Reverse direction for twinkling
                        }
                    }
                    canvas.requestPaint();
                }
            }
        }
    }

    MouseArea {
        id: loginScreenRoot
        anchors.fill: parent

        property bool uiVisible: true
        property bool blockUI: mainStack.depth > 1 || userListComponent.mainPasswordBox.text.length > 0 || inputPanel.keyboardActive || config.type != "image"

        hoverEnabled: true
        drag.filterChildren: true
        onPressed: uiVisible = true;
        onPositionChanged: uiVisible = true;
        onUiVisibleChanged: {
            if (blockUI) {
                fadeoutTimer.running = false;
            } else if (uiVisible) {
                fadeoutTimer.restart();
            }
        }
        onBlockUIChanged: {
            if (blockUI) {
                fadeoutTimer.running = false;
                uiVisible = true;
            } else {
                fadeoutTimer.restart();
            }
        }

        Keys.onPressed: {
            uiVisible = true;
            event.accepted = false;
        }

        //takes one full minute for the ui to disappear
        Timer {
            id: fadeoutTimer
            running: true
            interval: 60000
            onTriggered: {
                if (!loginScreenRoot.blockUI) {
                    loginScreenRoot.uiVisible = false;
                }
            }
        }

        PlasmaComponents.ToolButton {
            text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to show/hide virtual keyboard", "Virtual Keyboard")
            font.pointSize: config.fontSize
            icon.name: inputPanel.keyboardActive ? "input-keyboard-virtual-on" : "input-keyboard-virtual-off"
            onClicked: {
                // Otherwise the password field loses focus and virtual keyboard
                // keystrokes get eaten
                userListComponent.mainPasswordBox.forceActiveFocus();
                inputPanel.showHide()
            }
            visible: inputPanel.status == Loader.Ready
            anchors.left: mainStack.left
            anchors.top: mainStack.top
            anchors.topMargin: 10
            anchors.leftMargin: 10
        }

        KeyboardButton { }

        Clock {
            id: clock
            visible: true
            anchors.horizontalCenter: mainStack.horizontalCenter
            anchors.top: mainStack.top
            opacity: 0.8
        }

        StackView {
            id: mainStack
            anchors.centerIn: parent
            height: root.height / 1.3
            width: parent.width / 2

            focus: true //StackView is an implicit focus scope, so we need to give this focus so the item inside will have it

            Timer {
                running: true
                repeat: false
                interval: 200
                onTriggered: mainStack.forceActiveFocus()
            }
            
            initialItem: Login {
                id: userListComponent
                userListModel: userModel
                loginScreenUiVisible: loginScreenRoot.uiVisible
                userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                lastUserName: userModel.lastUser

                showUserList: {
                    if ( !userListModel.hasOwnProperty("count")
                    || !userListModel.hasOwnProperty("disableAvatarsThreshold"))
                        return (userList.y + mainStack.y) > 0

                    if ( userListModel.count == 0 ) return false

                    return userListModel.count <= userListModel.disableAvatarsThreshold && (userList.y + mainStack.y) > 0
                }

                notificationMessage: {
                    var text = ""
                    if (keystateSource.data["Caps Lock"]["Locked"]) {
                        text += i18nd("plasma_lookandfeel_org.kde.lookandfeel","Caps Lock is on")
                        if (root.notificationMessage) {
                            text += " • "
                        }
                    }
                    text += root.notificationMessage
                    return text
                }

                RowLayout {
                    id: footer
                    width: parent.width
                    height: implicitHeight
                    anchors {
                        top: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }

                    Behavior on opacity {
                        OpacityAnimator {
                            duration: units.longDuration
                        }
                    }

                    SessionButton {
                        id: sessionButton
                        Rectangle {
                            anchors.fill: parent
                            color: "#ffffff"
                            opacity: 0.15
                            radius: 20
                        }
                        opacity: 0.7
                                    anchors.fill: parent
            anchors.leftMargin: -20
            anchors.rightMargin: -20
            anchors.topMargin: -2
            anchors.bottomMargin: -2
                    }

                    Battery { }
                }

                actionItems: [
                    ActionButton {
                        iconSource: Qt.resolvedUrl("assets/suspend.svg")
                        text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel","Suspend to RAM","Sleep")                        
                        onClicked: sddm.suspend()
                        enabled: sddm.canSuspend
                        visible: !inputPanel.keyboardActive
                    },
                    ActionButton {
                        iconSource: Qt.resolvedUrl("assets/restart.svg")
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Restart")
                        onClicked: sddm.reboot()
                        enabled: sddm.canReboot
                        visible: !inputPanel.keyboardActive
                    },
                    ActionButton {
                        iconSource: Qt.resolvedUrl("assets/shutdown.svg")
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Shut Down")
                        onClicked: sddm.powerOff()
                        enabled: sddm.canPowerOff
                        visible: !inputPanel.keyboardActive
                    }
                ]

                onLoginRequest: {
                    root.notificationMessage = ""
                    sddm.login(username, password, sessionButton.currentIndex)
                }

                Behavior on opacity {
                    OpacityAnimator {
                        duration: units.longDuration
                    }
                }
            }
        }

        VirtualKeyboardLoader {
            id: inputPanel
            z: 1
            screenRoot: root
            mainStack: mainStack
            mainBlock: userListComponent
            passwordField: userListComponent.mainPasswordBox
        }

        Rectangle {
            id: formBg
            width: mainStack.width
            height: mainStack.height
            x: root.width / 2 - width / 2
            y: root.height / 2 - height / 2
            radius: 16
            color: "#1e1e1e"
            opacity: 0.85
            z:-1
        }
    }

    Connections {
        target: sddm
        onLoginFailed: {
            notificationMessage = i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login Failed")
        }
    }

    onNotificationMessageChanged: {
        if (notificationMessage) {
            notificationResetTimer.start();
        }
    }

    Timer {
        id: notificationResetTimer
        interval: 3000
        onTriggered: notificationMessage = ""
    }
}
