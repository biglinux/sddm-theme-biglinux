/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
    SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

Loader {
    id: loader

    required property Item screenRoot
    required property T.StackView mainStack
    required property /* MainBlock | Login */ Item mainBlock
    required property T.TextField passwordField

    readonly property bool keyboardActive: item?.active ?? false

    function showHide() {
        state = state === "hidden" ? "visible" : "hidden";
    }

    source: Qt.platform.pluginName.includes("wayland")
        ? Qt.resolvedUrl("./VirtualKeyboard_wayland.qml")
        : Qt.resolvedUrl("./VirtualKeyboard.qml")

    onKeyboardActiveChanged: {
        if (keyboardActive) {
            state = "visible";
            // Otherwise the password field loses focus and virtual keyboard
            // keystrokes get eaten
            passwordField.forceActiveFocus();
        } else {
            state = "hidden";
        }
    }

    anchors {
        left: parent.left
        right: parent.right
    }

    state: "hidden"

    // mainStack is a centered card: these states own its y, so Main.qml anchors it horizontally only.
    states: [
        State {
            name: "visible"
            PropertyChanges {
                mainStack.y: Math.min((screenRoot.height - mainStack.height) / 2, screenRoot.height - loader.height - mainBlock.visibleBoundary)
                loader.y: screenRoot.height - loader.height
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                mainStack.y: (screenRoot.height - mainStack.height) / 2
                loader.y: screenRoot.height * 0.75
            }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"
            to: "visible"
            SequentialAnimation {
                ScriptAction {
                    script: {
                        loader.item.activated = true;
                        Qt.inputMethod.show();
                    }
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: loader.mainStack
                        property: "y"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: loader
                        property: "y"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.OutQuad
                    }
                }
            }
        },
        Transition {
            from: "visible"
            to: "hidden"
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        target: loader.mainStack
                        property: "y"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: loader
                        property: "y"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InQuad
                    }
                }
                ScriptAction {
                    script: {
                        loader.item.activated = false;
                        Qt.inputMethod.hide();
                    }
                }
            }
        }
    ]
}
