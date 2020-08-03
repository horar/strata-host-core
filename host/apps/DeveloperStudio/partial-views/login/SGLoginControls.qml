import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.0
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.12
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/login_utilities.js" as Authenticator
import "qrc:/js/login_storage.js" as UsernameStorage
import "qrc:/partial-views/login/"
import "qrc:/partial-views/"

import tech.strata.fonts 1.0
import tech.strata.logger 1.0
import tech.strata.sgwidgets 1.0

Item {
    id: root
    Layout.preferredHeight: loginControls.implicitHeight
    Layout.fillWidth: true

    property bool animationsRunning: failedLoginAnimation.running || hideFailedLoginAnimation.running
    property bool connecting: connectionStatus.visible

    ColumnLayout {
        id: loginControls
        width: root.width
        spacing: 20

        LoginComboBox {
            id: usernameField
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            font {
                pixelSize: 15
                family: Fonts.franklinGothicBook
            }
            borderColor: "transparent"
            model: ListModel {}
            textRole: "name"
            placeholderText: "Username/Email"
            editable: true

            property string text: ""

            onEditTextChanged: {
                editText = limitStringLength(editText)
                text = editText
            }

            onCurrentTextChanged: text = currentText

            onActivated: {
                if(index >= 0) {
                    usernameField.editText = model.get(index).name
                }
            }

            Keys.onPressed: {
                hideFailedLoginAnimation.startAnimation()
            }

            Keys.onReturnPressed:{
                loginButton.submit()
            }

            KeyNavigation.tab: passwordField

            // CTOR
            Component.onCompleted: {
                UsernameStorage.populateSavedUsernames(model, usernameFieldSettings.userNameStore)
                currentIndex = usernameFieldSettings.userNameIndex

                if (usernameField.text === "") {
                    forceActiveFocus()
                } else {
                    passwordField.forceActiveFocus()
                }
            } // end CTOR

            // DTOR
            Component.onDestruction: {
                usernameFieldSettings.userNameStore = UsernameStorage.saveSessionUsernames(model, usernameFieldSettings.userNameStore) // save logins from session into userNameStore
                usernameFieldSettings.userNameIndex = currentIndex;     // point to last login
            } // end DTOR

            function updateModel() {
                var lowerCase = text.toLowerCase()
                if (find(lowerCase) === -1) {
                    model.append({"name": lowerCase})
                    currentIndex = model.count-1
                } else {
                    currentIndex = find(lowerCase)
                }
            }

            function limitStringLength(string) {
                var newString = string
                if (string.length > 256) {
                    newString = newString.substring(0,255)
                }
                return newString
            }

            Settings {
                id: usernameFieldSettings
                category: "Usernames"
                property string userNameStore: "[]"
                property int userNameIndex: -1
            }
        }

        ValidationField {
            id: passwordField
            Layout.fillWidth: true
            activeFocusOnTab: true
            echoMode: TextInput.Password
            selectByMouse: true
            KeyNavigation.tab: loginButton.enabled ? loginButton : usernameField
            placeholderText: qsTr("Password")
            showIcon: false

            Keys.onPressed: {
                hideFailedLoginAnimation.startAnimation()
            }

            Keys.onReturnPressed:{
                loginButton.submit()
            }
        }

        Rectangle {
            id: loginErrorRect
            Layout.preferredWidth: usernameField.width
            Layout.preferredHeight: 0
            color:"red"
            visible: Layout.preferredHeight > 0
            clip: true

            SGIcon {
                id: alertIcon
                source: "qrc:/sgimages/exclamation-circle-solid.svg"
                anchors {
                    left: loginErrorRect.left
                    verticalCenter: loginErrorRect.verticalCenter
                    leftMargin: 5
                }
                height: 30
                width: 30
                iconColor: "white"
            }

            Text {
                id: loginErrorText
                font {
                    pixelSize: 10
                    family: Fonts.franklinGothicBold
                }
                wrapMode: Label.WordWrap
                anchors {
                    left: alertIcon.right
                    right: loginErrorRect.right
                    rightMargin: 5
                    verticalCenter: loginErrorRect.verticalCenter
                }
                horizontalAlignment:Text.AlignHCenter
                text: ""
                color: "white"
            }
        }

        Text {
            id: forgotLink
            Layout.alignment: Qt.AlignRight
            text: "Forgot Password"
            color: forgotLink.pressed ? "#ddd" : "#545960"
            font.underline: forgotMouse.containsMouse

            MouseArea {
                id: forgotMouse
                anchors.fill: forgotLink
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: {
                    forgotPopup.visible = true
                }
            }
        }

        Item {
            id: loginButtonContainer
            Layout.preferredHeight: loginButton.height
            Layout.preferredWidth: loginButton.width

            Button {
                id: loginButton
                width: usernameField.width
                height: usernameField.height
                text:"Login"
                activeFocusOnTab: true
                enabled: passwordField.text !== "" && usernameField.text !== ""

                background: Rectangle {
                    color: !loginButton.enabled ? "#dbdbdb" : loginButton.down ? "#666" : "#545960"

                    Rectangle {
                        color: "transparent"
                        anchors {
                            fill: parent
                        }
                        border.width: 2
                        border.color: "white"
                        opacity: .5
                        visible: loginButton.focus
                    }
                }

                contentItem: Text {
                    text: loginButton.text
                    color: !loginButton.enabled ? "#f2f2f2" : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBook
                    }
                }

                Keys.onReturnPressed:{
                    loginButton.submit()
                }

                onClicked: {
                    loginControls.visible = false
                    var timezone = -(new Date(new Date().getFullYear(), 0, 1)).getTimezoneOffset()/60
                    // API currently accepts an int, round towards zero:
                    if (timezone < 0) {
                        timezone = Math.ceil(timezone)
                    } else {
                        timezone = Math.floor(timezone)
                    }
                    var login_info = { user: usernameField.text, password: passwordField.text, timezone: timezone }
                    Authenticator.login(login_info)
                }

                function submit() {
                    if (loginButton.enabled) {
                        loginButton.clicked()
                    }
                }

                MouseArea {
                    id: loginButtonMouse
                    anchors.fill: loginButton
                    onPressed:  mouse.accepted = false
                    cursorShape: Qt.PointingHandCursor
                }

                ToolTip {
                    text: {
                        var result = ""

                        if (usernameField.text === "" ){
                            result += "Username required"
                        }
                        if (passwordField.text === "" ){
                            result += (result === "" ? "" : "<br>")
                            result += "Password required"
                        }
                        return result
                    }
                    visible: loginToolTipShow.containsMouse && !loginButton.enabled && !forgotPopup.visible
                }
            }

            MouseArea {
                id: loginToolTipShow
                anchors.fill: loginButton
                hoverEnabled: true
                visible: !loginButton.enabled
            }
        }
    }

    ConnectionStatus {
        id: connectionStatus
        anchors {
            centerIn: parent
        }
        visible: !loginControls.visible
    }

    Connections {
        target: Authenticator.signals
        onLoginResult: {
            var resultObject = JSON.parse(result)
            //console.log(Logger.devStudioCategory, "Login result received")
            if (resultObject.response === "Connected") {
                connectionStatus.text = "Connected, Loading UI..."
                var data = { "user_id": resultObject.user_id, "first_name":resultObject.first_name, "last_name": resultObject.last_name }
                NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT,data)
                usernameField.updateModel()
            } else {
                loginControls.visible = true
                connectionStatus.text = ""
                if (resultObject.response === "No Connection") {
                    loginErrorText.text = "Connection to authentication server failed"
                } else {
                    loginErrorText.text = "Username and/or password is incorrect"
                }
                failedLoginAnimation.start()
            }
        }
    }

    NumberAnimation{
        id: failedLoginAnimation
        target: loginErrorRect
        property: "Layout.preferredHeight"
        to: usernameField.height + 10
        duration: 200
    }

    NumberAnimation{
        id: hideFailedLoginAnimation
        target: loginErrorRect
        property: "Layout.preferredHeight"
        to: 0
        duration: 200
        onStopped: {
            if (!animationsRunning) {
                loginErrorText.text = ""
            }
        }

        function startAnimation () {
            if (loginErrorRect.height !== 0 && !animationsRunning) {
                start()
            }
        }
    }
}
