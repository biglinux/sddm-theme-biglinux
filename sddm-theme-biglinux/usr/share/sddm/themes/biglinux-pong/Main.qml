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
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import Qt5Compat.GraphicalEffects 1.0
import org.kde.plasma.plasma5support 2.0 as Plasma5Support
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.15 as Kirigami
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

    Plasma5Support.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    Rectangle {
        id: gameArea
        anchors.fill: parent
        color: "#282828"
        width: 100; height: 100
        SequentialAnimation on color {
            running: true
                    loops: Animation.Infinite
          ColorAnimation { to: "#140000"; duration: 10000 }
          ColorAnimation { to: "#001400"; duration: 10000 }
          ColorAnimation { to: "#140a00"; duration: 10000 }
          ColorAnimation { to: "#0d0014"; duration: 10000 }
          ColorAnimation { to: "#000e14"; duration: 10000 }
          ColorAnimation { to: "#0a140e"; duration: 10000 }
          ColorAnimation { to: "#14140a"; duration: 10000 }
          ColorAnimation { to: "#140714"; duration: 10000 }
        }
        property int leftScore: 0
        property int rightScore: 0
        property real speedFactor: 2.0
        property bool isPaused: false

        function resetBall() {
            ball.x = gameArea.width / 2 - ball.width / 2;
            ball.y = gameArea.height / 2 - ball.height / 2;
            ball.dx = 8; // Double the initial speed
            ball.dy = 8; // Double the initial speed
            gameArea.speedFactor = 2.0;
        }

        function togglePause() {
            gameArea.isPaused = !gameArea.isPaused;
            ballTimer.running = !gameArea.isPaused;
        }

        Text {
            id: scoreDisplay
            text: "Player: " + gameArea.leftScore + " - Computer: " + gameArea.rightScore
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            font.pixelSize: 24
            opacity: 0.6
        }

        // Button pause
        Rectangle {
            id: pauseButton
            width: 40
            height: 40
            color: "transparent"
            z: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.margins: 10
            border.color: "transparent"

            Rectangle {
                id: leftPauseLine
                width: 8
                height: 20
                color: "white"
                opacity: 0.6
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -6
            }

            Rectangle {
                id: rightPauseLine
                width: 8
                height: 20
                color: "white"
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 6
                opacity: 0.6
            }
        }

        // Player paddle
        Rectangle {
            id: leftPaddle
            width: 20
            radius: 10
            height: 150
            color: "white"
            x: 10
            y: gameArea.height / 2 - height / 2
            opacity: 0.6
        }

        // Computer paddle
        Rectangle {
            id: rightPaddle
            width: 20
            radius: 10
            height: 150
            color: "white"
            x: gameArea.width - width - 10
            y: gameArea.height / 2 - height / 2
            opacity: 0.6
        }

        // Ball
        Rectangle {
            id: ball
            width: 20
            height: 20
            radius: 10
            color: "white"
            x: gameArea.width / 2 - width / 2
            y: gameArea.height / 2 - height / 2

            property int dx: 8 // Double the initial speed
            property int dy: 8 // Double the initial speed

            Timer {
                id: ballTimer
                interval: 30 // Adjust as needed
                running: true
                repeat: true
                onTriggered: {
                    if (!gameArea.isPaused) {
                        // Move ball
                        ball.x += ball.dx * gameArea.speedFactor;
                        ball.y += ball.dy * gameArea.speedFactor;

                        // Ball collision with top and bottom
                        if (ball.y <= 0 || ball.y >= gameArea.height - ball.height) {
                            ball.dy *= -1;
                        }

                        // Ball collision with paddles
                        if (ball.x <= leftPaddle.x + leftPaddle.width && ball.y + ball.height >= leftPaddle.y && ball.y <= leftPaddle.y + leftPaddle.height) {
                            ball.dx *= -1;
                            gameArea.speedFactor *= 1.05; // Increase speed by 10%
                        }
                        if (ball.x + ball.width >= rightPaddle.x && ball.y + ball.height >= rightPaddle.y && ball.y <= rightPaddle.y + rightPaddle.height) {
                            ball.dx *= -1;
                            gameArea.speedFactor *= 1.05; // Increase speed by 10%
                        }

                        // Ball out of bounds
                        if (ball.x <= 0) {
                            gameArea.rightScore += 1;
                            gameArea.resetBall();
                        } else if (ball.x >= gameArea.width - ball.width) {
                            gameArea.leftScore += 1;
                            gameArea.resetBall();
                        }

                        // AI for right paddle
                        // Increase the movement speed and improve logic
                        if (ball.y < rightPaddle.y + rightPaddle.height / 2) {
                            rightPaddle.y += Math.min(180, ball.y - rightPaddle.y * 1.15); // Faster and smarter reaction
                        } else if (ball.y > rightPaddle.y + rightPaddle.height / 2) {
                            rightPaddle.y += Math.min(180, ball.y - rightPaddle.y * 1.15); // Faster and smarter reaction
                        }
                    }
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
            onPositionChanged: {
                if (!gameArea.isPaused) {
                    leftPaddle.y = Math.max(0, Math.min(mouse.y - leftPaddle.height / 2, gameArea.height - leftPaddle.height));
                }
                uiVisible = true;
            }
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

        Rectangle {
            id: formBg
            width: mainStack.width
            height: mainStack.height
            x: root.width / 2 - width / 2
            y: root.height / 2 - height / 2
            radius: 16
            color: "#1e1e1e"
            opacity: 0.6
            z: -1
            visible: true
        }

        StackView {
            id: mainStack
            anchors.centerIn: parent
            width: {
                if (Screen.width >= 1700) {
                    return parent.width / 1.8;
                } else {
                    return parent.width / 1.4;
                }
            }
            height: {
                if (Screen.height >= 950) {
                    return root.height / 1.3;
                } else {
                    return root.height / 1.05;
                }
            }

            focus: true // StackView is an implicit focus scope, so we need to give this focus so the item inside will have it

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
            
            
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                anchors.margins: -root.width
                hoverEnabled: true
                onClicked: {
                    gameArea.togglePause();
                }
                onPositionChanged: {
                    if (!gameArea.isPaused) {
                        leftPaddle.y = Math.max(0, Math.min(mouse.y - leftPaddle.height / 2, gameArea.height - leftPaddle.height));
                    }
                }
                onEntered: {
                    leftPauseLine.color = "lightgrey";
                    rightPauseLine.color = "lightgrey";
                }
                onExited: {
                    leftPauseLine.color = "white";
                    rightPauseLine.color = "white";
                }
            }

            initialItem: Login {
                id: userListComponent
                userListModel: userModel
                loginScreenUiVisible: loginScreenRoot.uiVisible
                userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                lastUserName: userModel.lastUser

                showUserList: {
                    if (!userListModel.hasOwnProperty("count")
                        || !userListModel.hasOwnProperty("disableAvatarsThreshold"))
                        return (userList.y + mainStack.y) > 0

                    if (userListModel.count == 0) return false

                    return userListModel.count <= userListModel.disableAvatarsThreshold && (userList.y + mainStack.y) > 0
                }

                notificationMessage: {
                    var text = ""
                    if (keystateSource.data["Caps Lock"]["Locked"]) {
                        text += i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Caps Lock is on")
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
                }

                Item {
                    id: phrase
                    anchors.top: footer.bottom
                    anchors.topMargin: Screen.height / 22
                    anchors.horizontalCenter: parent.horizontalCenter  // Centraliza horizontalmente

                    visible: true
                    Text {
                        id: commandStdout
                        color: "#fff"
                        opacity: 0.7
                        anchors.horizontalCenter: parent.horizontalCenter  // Centraliza horizontalmente
                        wrapMode: Text.Wrap // Adiciona quebra de linha se necessário
                        textFormat: Text.PlainText
                        width: mainStack.width - 200
                        horizontalAlignment: Text.AlignHCenter // Centraliza o texto horizontalmente
                        font.pointSize: config.fontSize
                        font.family: config.font
                     }

                    Plasma5Support.DataSource {
                        id: phrases
                        engine: "executable"
                        connectedSources: "/usr/share/sddm/scripts/sortphrases"
                        onNewData: (sourceName, data) => {
                            var exitCode = data["exit code"]
                            var exitStatus = data["exit status"]
                            var stdout = data["stdout"]
                            var stderr = data["stderr"]
                            if (exitCode === 0 && exitStatus === 0) {
                                commandStdout.text = stdout.trim()
                                // } else {
                                //     commandStdout.text = "Error: " + stderr
                            }
                            disconnectSource(sourceName)
                        }
                    }
                }

                actionItems: [
                    ActionButton {
                        iconSource: Qt.resolvedUrl("assets/suspend.svg")
                        text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Suspend to RAM", "Sleep")
                        onClicked: sddm.suspend()
                        enabled: sddm.canSuspend
                        visible: !inputPanel.keyboardActive
                    },
                    ActionButton {
                        iconSource: Qt.resolvedUrl("assets/restart.svg")
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                        onClicked: sddm.reboot()
                        enabled: sddm.canReboot
                        visible: !inputPanel.keyboardActive
                    },
                    ActionButton {
                        iconSource: Qt.resolvedUrl("assets/shutdown.svg")
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
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

PlasmaComponents.ToolButton {
    id: virtualKeyboardButton
    // Não define o texto diretamente aqui para evitar duplicação
    font.pointSize: config.fontSize
    opacity: 0.6
    width: virtualKeyboardButtonLabel.width + 50
    height: 30
    
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
    anchors.leftMargin: 20

    contentItem: Row {
        spacing: 5
        id: iconVirtualKeyboard
        anchors.centerIn: parent
        z: -2
        Kirigami.Icon {
            source: virtualKeyboardButton.icon.name
            width: 24
            height: 24
        }

        Text {
            id: virtualKeyboardButtonLabel
            text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to show/hide virtual keyboard", "Virtual Keyboard")
            color: "transparent" // Inicialmente transparente
            font.pointSize: config.fontSize
            anchors.right: iconVirtualKeyboard.right
            anchors.rightMargin: 10
        }

        MouseArea {
            id: hoverAreaKeyboard
            anchors.fill: parent
            hoverEnabled: true

            onEntered: virtualKeyboardButtonLabel.color = "white"  // Cor visível
            onExited: virtualKeyboardButtonLabel.color = "transparent" // Cor transparente
        }
    }
}

KeyboardButton { }
            Battery {
                anchors.right: mainStack.right
                anchors.top: mainStack.top
                anchors.topMargin: 10
                anchors.rightMargin: 25
            }

            Clock {
                id: clock
                visible: true
                anchors.horizontalCenter: mainStack.horizontalCenter
                anchors.top: mainStack.top
                anchors.topMargin: 20
                opacity: 0.8
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


        ShaderEffectSource {
            id: blurSource
            sourceItem: wallpaper
            anchors.fill: formBg
            sourceRect: Qt.rect(formBg.x, formBg.y, formBg.width, formBg.height)
            visible: false
        }

        MultiEffect {
            source: blurSource
            anchors.fill: formBg

            autoPaddingEnabled: true
            blurEnabled: true
            blurMax: 64
            blur: 1.0
            z: -2
        }
    }

Connections {
    target: sddm
    function onLoginFailed() {
        notificationMessage = i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login Failed");
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
