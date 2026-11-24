/*
    Compatibility shim for Plasma 6.8 and later.

    Plasma 6.8 dropped VirtualKeyboardLoader from org.kde.breeze.components
    (plasma-workspace commit f1c83d1537). This theme's Main.qml still creates
    one, so without this file the theme fails with "VirtualKeyboardLoader is not
    a type" and SDDM falls back to its embedded theme.

    Keeps the old API, backed by KWinVirtualKeyboard, which is what the stock
    Breeze theme uses since 6.8. Safe to delete once the theme is updated to
    call KWinVirtualKeyboard directly like Breeze.
*/

import QtQuick

import org.kde.plasma.workspace.keyboardlayout as Keyboards

Item {
    // Assigned by Main.qml. A keyboard driven by KWin needs none of them.
    property var screenRoot
    property var mainStack
    property var mainBlock
    property var passwordField

    readonly property bool keyboardActive: Keyboards.KWinVirtualKeyboard.visible
    readonly property int status: Keyboards.KWinVirtualKeyboard.available ? Loader.Ready : Loader.Null

    function showHide() {
        if (Keyboards.KWinVirtualKeyboard.visible) {
            Keyboards.KWinVirtualKeyboard.active = false;
        } else {
            Keyboards.KWinVirtualKeyboard.forceActivate();
        }
    }
}
