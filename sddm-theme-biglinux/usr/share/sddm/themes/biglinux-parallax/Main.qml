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
        width: parent.width
        height: parent.height

        Image {
            id: wallpaper
            source: config.type == "color" || !config.background ? config.auto_background : config.background
            asynchronous: false
            cache: true
            clip: true
            visible: true
            scale: 1.2 // Zoom de 20%
            anchors.centerIn: parent // Centraliza a imagem
            transform: Translate {
                id: translateTransform
                x: 0
                y: 0
            }
        }

        Canvas {
            id: canvas
            anchors.fill: parent
            property var meteors: []
            property var particles: []

            function createMeteor() {
                return {
                    x: Math.random() * canvas.width,
                    y: Math.random() * canvas.height,
                    size: Math.random() * 2 + 1,
                    opacity: Math.random() * 0.5 + 0.5,
                    speed: Math.random() * 5 + 5,
                    length: Math.random() * 20 + 10,
                    color: "rgba(255, 255, 255, 0.8)"
                };
            }

            function createParticle() {
                return {
                    x: Math.random() * canvas.width,
                    y: Math.random() * canvas.height,
                    size: Math.random() * 3 + 1,
                    opacity: Math.random() * 0.5 + 0.5,
                    speedX: Math.random() * 2 - 1,
                    speedY: Math.random() * 2 - 1,
                    color: "rgba(255, 255, 255, 0.5)"
                };
            }

            onPaint: {
                var ctx = canvas.getContext("2d");
                ctx.clearRect(0, 0, canvas.width, canvas.height);

                // Draw meteors
                for (var i = 0; i < meteors.length; i++) {
                    var meteor = meteors[i];
                    ctx.beginPath();
                    ctx.moveTo(meteor.x, meteor.y);
                    ctx.lineTo(meteor.x + meteor.length, meteor.y + meteor.length);
                    ctx.strokeStyle = meteor.color;
                    ctx.lineWidth = meteor.size;
                    ctx.stroke();
                }

                // Draw particles
                for (var i = 0; i < particles.length; i++) {
                    var particle = particles[i];
                    ctx.save();
                    ctx.beginPath();
                    ctx.arc(particle.x, particle.y, particle.size, 0, 2 * Math.PI, false);
                    ctx.fillStyle = particle.color;
                    ctx.globalAlpha = particle.opacity;
                    ctx.fill();
                    ctx.restore();
                }
            }

            Component.onCompleted: {
                for (var i = 0; i < 20; i++) { // Increase the number of meteors
                    meteors.push(createMeteor());
                }

                for (var i = 0; i < 50; i++) { // Increase the number of particles
                    particles.push(createParticle());
                }

                canvas.requestPaint();
            }

            Timer {
                interval: 70 // Increase interval to reduce CPU usage
                running: true
                repeat: true
                onTriggered: {
                    // Occasionally create a meteor
                    if (Math.random() < 0.1) {
                        canvas.meteors.push(canvas.createMeteor());
                    }

                    // Update meteors
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

                    // Update particles
                    for (var i = 0; i < canvas.particles.length; i++) {
                        var particle = canvas.particles[i];
                        particle.x += particle.speedX;
                        particle.y += particle.speedY;
                        particle.opacity -= 0.01;
                        if (particle.opacity <= 0) {
                            canvas.particles.splice(i, 1); // Remove the particle
                            canvas.particles.push(canvas.createParticle()); // Add new particle
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

        ShaderEffectSource {
            id: blurSource
            sourceItem: wallpaper
            anchors.fill: formBg
            sourceRect: Qt.rect(formBg.x, formBg.y, formBg.width, formBg.height)
            visible: false
            mipmap: false
            live: false
        }

        MultiEffect {
            source: blurSource
            anchors.fill: formBg

            autoPaddingEnabled: true
            blurEnabled: true
            blurMax: 64
            blur: 1.0
            blurMultiplier: 1.0
            z: -2
            anchors.leftMargin: -30
            anchors.rightMargin: -30
            anchors.topMargin: -30
            anchors.bottomMargin: -30
        }

        Rectangle {
            id: formBg
            width: mainStack.width
            height: mainStack.height
            x: root.width / 2 - width / 2
            y: root.height / 2 - height / 2
            radius: 16
            color: "#1e1e1e"
            opacity: 0.8
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
                    var backgroundParallaxFactor = 0.02; // Adjust background parallax effect

                    // Move the background
                    translateTransform.x = mouse.x * backgroundParallaxFactor;
                    translateTransform.y = mouse.y * backgroundParallaxFactor;

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
