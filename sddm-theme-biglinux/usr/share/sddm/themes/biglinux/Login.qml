import "components"

import QtQuick 2.0
import QtQuick.Layouts 1.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

SessionManagementScreen {
    id: root
    property Item mainPasswordBox: passwordBox

    property bool showUsernamePrompt: !showUserList

    property string lastUserName
    property bool loginScreenUiVisible: false

    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + units.smallSpacing

    property int fontSize: parseInt(config.fontSize)

    signal loginRequest(string username, string password)

    onShowUsernamePromptChanged: {
        if (!showUsernamePrompt) {
            lastUserName = ""
        }
    }

    /*
    * Login has been requested with the following username and password
    * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
    */
    function startLogin() {
        var username = userList.selectedUser
        var password = passwordBox.text
        mainStack.enabled = false
        userListComponent.userList.opacity = 0.5

        //this is partly because it looks nicer
        //but more importantly it works round a Qt bug that can trigger if the app is closed with a TextField focused
        //DAVE REPORT THE FRICKING THING AND PUT A LINK
        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    PlasmaComponents3.TextField {
        id: userNameInput
        font.pointSize: fontSize + 1
        Layout.fillWidth: true

        text: lastUserName
        visible: showUsernamePrompt
        focus: showUsernamePrompt && !lastUserName //if there's a username prompt it gets focus first, otherwise password does
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Username")

        onAccepted:
            if (root.loginScreenUiVisible) {
                passwordBox.forceActiveFocus()
            }
    }
            
RowLayout {
    Layout.fillWidth: true
    spacing: 40
    PlasmaExtras.PasswordField {
            id: passwordBox
            
            color : "#fff"
            font.pointSize: fontSize + 4
            Layout.fillWidth: true
            Layout.leftMargin: 20
            background: Rectangle {
                            id: passwordBoxStyle
                            border.color : "#fff"
                            anchors.centerIn: parent
                            width: parent.width + units.gridUnit
                            height: 40
                            radius: 50
                            color: "#000"
                            opacity: 0.5
                            border.width: 1
                        }

            placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
            focus: !showUsernamePrompt || lastUserName

            onAccepted: {
                if (root.loginScreenUiVisible) {
                    startLogin();
                }
            }

            Keys.onEscapePressed: {
                mainStack.currentItem.forceActiveFocus();
            }

            //if empty and left or right is pressed change selection in user switch
            //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
            Keys.onPressed: {
                if (event.key === Qt.Key_Left && !text) {
                    userList.decrementCurrentIndex();
                    event.accepted = true
                }
                if (event.key === Qt.Key_Right && !text) {
                    userList.incrementCurrentIndex();
                    event.accepted = true
                }
        }

        Connections {
            target: sddm
            function onLoginFailed() {
                passwordBox.selectAll()
                passwordBox.forceActiveFocus()
            }
        }
    }

    PlasmaComponents3.Button {
        id: loginButton
        Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log In")
        Layout.preferredHeight: passwordBox.implicitHeight
        Layout.preferredWidth: loginButton.Layout.preferredHeight
        background: Rectangle {
                        id: loginButtonStyle
                        border.color : "#fff"
                        anchors.centerIn: parent
                        width: parent.width + units.gridUnit 
                        height: passwordBoxStyle.height
                        radius: 50
                        color: "#000"
                        opacity: 0.3
                        border.width : 1
                   }
        icon.name: "/usr/share/sddm/themes/biglinux/components/artwork/go-next.svg"
    
        onClicked: startLogin();
    }

}
    
}
