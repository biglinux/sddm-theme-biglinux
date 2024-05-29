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
        width: parent.width
        height: parent.height

        // Gradient background
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0a0c19" }  // Darker blue at the top
            GradientStop { position: 0.5; color: "#090d1e" }  // Dark blue in the middle
            GradientStop { position: 1.0; color: "#111114" }  // Dark gray at the bottom
        }

        Canvas {
            id: canvas
            anchors.fill: parent
            property var stars: []
            property var meteors: []
            property real centerX: canvas.width / 2
            property real centerY: canvas.height / 2

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
                    baseX: Math.random() * canvas.width,
                    baseY: Math.random() * canvas.height,
                    depth: Math.random(), // Depth from 0 (closest) to 1 (farthest)
                    size: Math.random() * 2 + 1, // Small stars
                    opacity: Math.random(),
                    twinkleSpeed: Math.random() * 0.02 + 0.01, // Speed of twinkling
                    color: color
                };
            }

            function createMeteor() {
                return {
                    x: Math.random() * canvas.width,
                    y: Math.random() * canvas.height,
                    size: Math.random() * 2 + 1,
                    opacity: Math.random() * 0.5 + 0.5,
                    speed: Math.random() * 5 + 5,
                    length: Math.random() * 20 + 10
                };
            }

            onPaint: {
                var ctx = canvas.getContext("2d");
                ctx.clearRect(0, 0, canvas.width, canvas.height);

                // Draw stars
                for (var i = 0; i < stars.length; i++) {
                    var star = stars[i];
                    ctx.save();
                    ctx.beginPath();
                    ctx.arc(star.x, star.y, star.size, 0.5, 1.3 * Math.PI, false);
                    var gradient = ctx.createRadialGradient(star.x, star.y, 0, star.x, star.y, star.size);
                    gradient.addColorStop(0, "rgba(" + star.color.r + ", " + star.color.g + ", " + star.color.b + ", " + star.opacity + ")");
                    gradient.addColorStop(1, "rgba(" + star.color.r + ", " + star.color.g + ", " + star.color.b + ", 0)");
                    ctx.fillStyle = gradient;
                    ctx.fill();
                    ctx.restore();
                }

                // Draw meteors
                for (var i = 0; i < meteors.length; i++) {
                    var meteor = meteors[i];
                    ctx.beginPath();
                    ctx.moveTo(meteor.x, meteor.y);
                    ctx.lineTo(meteor.x + meteor.length, meteor.y + meteor.length);
                    ctx.strokeStyle = "rgba(255, 255, 255, " + meteor.opacity + ")";
                    ctx.lineWidth = meteor.size;
                    ctx.stroke();
                }
            }

            Component.onCompleted: {
                for (var i = 0; i < 400; i++) { // Increase the number of stars
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

                    // Occasionally create a meteor
                    if (Math.random() < 0.02) {
                        canvas.meteors.push(canvas.createMeteor());
                    }

                    for (var i = 0; i < canvas.meteors.length; i++) {
                        var meteor = canvas.meteors[i];
                        meteor.x += meteor.speed;
                        meteor.y += meteor.speed;
                        meteor.opacity -= 0.02;
                        if (meteor.opacity <= 0) {
                            canvas.meteors.splice(i, 1); // Remove the meteor
                            i--;
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
            opacity: 0.5
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
            anchors.topMargin: 20
            opacity: 0.8
        }

        StackView {
            id: mainStack
            anchors.centerIn: parent
            height: root.height / 1.3
            width: parent.width / 2

            focus: true //StackView is an implicit focus scope, so we need to give this focus so the item inside will have it

            MouseArea {
                anchors.fill: parent
                anchors.margins: -root.width
                hoverEnabled: true
                onPositionChanged: {
                    var parallaxFactor = 0.1; // Adjust parallax effect

                    for (var i = 0; i < canvas.stars.length; i++) {
                        var star = canvas.stars[i];
                        var depthFactor = (1 - star.depth) * parallaxFactor;
                        star.x = star.baseX + mouse.x * depthFactor;
                        star.y = star.baseY + mouse.y * depthFactor;
                    }

                    canvas.requestPaint();
                }
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
                            opacity: 0.1
                            radius: 20
                            anchors.leftMargin: -15
                            anchors.rightMargin: -15
                        }
                        opacity: 0.5
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
            color: "#1c1c1c"
            opacity: 0.7
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
