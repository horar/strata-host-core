import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Styles 1.4
import Qt.labs.settings 1.0
import "js/navigation_control.js" as NavigationControl
import "js/login.js" as Authenticator
import Fonts 1.0
import "qrc:/statusbar-partial-views"

Rectangle {
    id: container
    anchors { fill: parent }
    visible: true
    clip: true

    Component.onCompleted: {
        usernameField.forceActiveFocus();   // Allows the user to type their username without clicking
    }

    // Login Button Connection
    Connections {
        target: loginButton
        onClicked: {
            // Report Error if we are missing text
            if (usernameField.text=="" || passwordField.text==""){
                loginErrorText.text = "Username or password is blank"
                failedLoginAnimation.start();
            } else {
                // Pass info to Authenticator
                var login_info = { user: usernameField.text, password: passwordField.text }
                Authenticator.login(login_info)
                loginRectangle.enabled = false
            }
        }
    }

    Connections {
        target: Authenticator.signals
        onLoginResult: {
            //console.log("Login result received")
            if (result === "Connected") {
                connectionStatus.text = "Connected, Loading UI..."
                var data = { user_id: usernameField.text }
                NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT,data)
                usernameField.updateModel()
            } else {
                loginRectangle.enabled = true
                connectionStatus.text = ""
                if (result === "No Connection") {
                    loginErrorText.text = "Connection to authentication server failed"
                } else {
                    loginErrorText.text = "Your username or password are incorrect"
                }
                failedLoginAnimation.start()
            }
        }

        // [TODO][prasanth]: jwt will be created/received in the hcs
        // for now, jwt will be received in the UI and then sent to HCS
        onLoginJWT: {
            //console.log("JWT received",jwt_string)
            var jwt_json = {
                "hcs::cmd":"jwt_token",
                "payload": {
                    "jwt":jwt_string,
                    "user_name":usernameField.text
                }
            }
            console.log("sending the jwt json to hcs",JSON.stringify(jwt_json))
            coreInterface.sendCommand(JSON.stringify(jwt_json))
        }

        onConnectionStatus: {
            switch(status) {
                case 0:
                    connectionStatus.text = "Building Request"
                    break;
                case 1:
                    connectionStatus.text = "Waiting on Server Response"
                    break;
                case 2:
                    connectionStatus.text = "Request Received From Server"
                    break;
                case 3:
                    connectionStatus.text = "Processing Request"
            }
        }
    }

    //-----------------------------------------------------------
    //Elements common to both the connection and login screens
    //-----------------------------------------------------------
    Image {
        id: background
        source: "qrc:/images/login-background.svg"
        height: 1080
        width: 1920
        x: (parent.width - width)/2
        y: (parent.height - height)/2
    }

    Image {
        id: strataLogo
        width: 2 * height
        height: container.height < 560 ? 125 : 200
        anchors {
            horizontalCenter: container.horizontalCenter
            bottom: spyglassTextRect.top
        }
        source: "qrc:/images/strata-logo.svg"
        mipmap: true;
    }

    Rectangle {
        id: spyglassTextRect
        height: 0
        color: "#ffffff"
        anchors {
            horizontalCenter: container.horizontalCenter;
            verticalCenter: container.verticalCenter;
            verticalCenterOffset:  container.height < 560 ? 25 : 50
        }
    }

    Rectangle {
        id: onSemiHeader
        color: "#235a92"
        anchors {
            top: container.top
            left: container.left
            right: container.right
        }
        height: 130
        clip: true

        Image {
            id: onSemiLogo
            source: "qrc:/images/on-semi-logo.png"
            anchors {
                left: onSemiHeader.left
                leftMargin: 25
                verticalCenter: onSemiHeader.verticalCenter
            }
        }
    }

    //-----------------------------------------------------------
    // login screen elements
    //-----------------------------------------------------------

    Item {
        id: loginRectangle
        width: 184
        height: 125
        anchors {
            horizontalCenter: container.horizontalCenter;
            top: spyglassTextRect.bottom
            topMargin: 15
        }

        SGComboBox {
            id: usernameField

            comboBoxHeight: 38
            focus: true
            property string text: currentText
            onEditTextChanged: text = editText
            onCurrentIndexChanged: text = currentText

            editable: true
            borderColor: "#ddd"
            model: ListModel {}
            placeholderText: "Username"

            Component.onCompleted: {
                var userNames = JSON.parse(userNameFieldSettings.userNameStore)
                for (var i = 0; i < userNames.length; ++i) {
                    model.append(userNames[i])
                }
                currentIndex = userNameFieldSettings.userNameIndex
            }
            Component.onDestruction: {
                var userNames = []
                for (var i = 0; i < model.count; ++i) {
                    userNames.push(model.get(i))
                }
                userNameFieldSettings.userNameStore = JSON.stringify(userNames)
                userNameFieldSettings.userNameIndex = currentIndex
            }

            anchors {
                top: loginRectangle.top
                left: loginRectangle.left
                right: loginRectangle.right
            }
            comboBoxWidth: loginRectangle.width

            Keys.onPressed: {
                hideFailedLoginAnimation.start()
            }

            //handle a return key click, which is the equivalent of the login button being clicked
            Keys.onReturnPressed:{
                loginButton.clicked()
            }

            function updateModel() {
                if (find(text) === -1) {
                    model.append({text: text})
                    currentIndex = find(text)
                }
            }

            font {
                pixelSize: 15
                family: Fonts.franklinGothicBook
            }

            Settings {
                id: userNameFieldSettings

                property string userNameStore: "{}"
                property int userNameIndex: -1
            }
        }

        TextField {
            id: passwordField
            anchors{
                top: usernameField.bottom
                topMargin: 2
                left: loginRectangle.left
                right: loginRectangle.right
            }
            height: 38
            activeFocusOnTab: true
            placeholderText: qsTr("Password")
            echoMode: TextInput.Password
            font {
                pixelSize: 15
                family: Fonts.franklinGothicBook
            }
            background: Rectangle {
                border.color: passwordField.activeFocus ? "#219647" : "#ddd"
            }
            selectByMouse: true
            KeyNavigation.tab: loginButton

            Keys.onPressed: {
                hideFailedLoginAnimation.start()
            }
            //handle a return key click, which is the equivalent of the login button being clicked
            Keys.onReturnPressed:{
                loginButton.clicked()
            }
        }

        Rectangle{
            id:loginErrorRect
            width: loginRectangle.width
            height: 48
            color:"red"
            opacity: 0.0
            anchors {
                horizontalCenter: loginRectangle.horizontalCenter
                top: passwordField.bottom
                topMargin: 5
            }

            Image{
                id:alertIcon
                source: "./images/icons/whiteAlertIcon.svg"
                anchors{left:loginErrorRect.left; top:loginErrorRect.top; bottom:loginErrorRect.bottom
                    leftMargin: 5; topMargin:10; bottomMargin:10}
                fillMode:Image.PreserveAspectFit
                mipmap: true;
            }

            Text{
                id:loginErrorText
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

        Button {
            id: loginButton
            anchors {
                bottom: loginRectangle.bottom
                topMargin: 2
                horizontalCenter: loginRectangle.horizontalCenter
            }
            width: 184; height: 38
            text:"Login"
            activeFocusOnTab: true

            background: Rectangle {
                color: loginButton.down ? "#666" : "#888"
                border.color: loginButton.activeFocus ? "#219647" : "transparent"
            }

            contentItem: Text {
                text: loginButton.text
                opacity: enabled ? 1.0 : 0.3
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font {
                    pixelSize: 15
                    family: Fonts.franklinGothicBold
                }
            }

            Keys.onReturnPressed:{
                loginButton.clicked()
            }

            /* OnClicked is handled in Connections section above */
        }
    }

    //-----------------------------------------------------------
    // connecting status elements
    //-----------------------------------------------------------
    Item {
        id: connectingStatus
        anchors {
            fill: loginRectangle
        }
        visible: !loginRectangle.enabled

        Rectangle {
            id: coverup
            color: "white"
            opacity: 0.75
            anchors {
                fill: parent
            }
        }

        Text {
            id: searchingText
            color: "#888"
            text: "Connecting..."
            anchors {
                horizontalCenter: connectingStatus.horizontalCenter
                top: connectingStatus.top
                topMargin: 25
            }
            horizontalAlignment: Text.AlignHCenter
            font {
                family: Fonts.franklinGothicBold
            }
        }

        Text {
            id: connectionStatus
            color: "#888"
            text: ""
            anchors {
                horizontalCenter: searchingText.horizontalCenter
                top: searchingText.bottom
                topMargin: 3
            }
            horizontalAlignment: Text.AlignHCenter
            font {
                family: Fonts.franklinGothicBook
            }

//            onTextChanged: console.log("Connection Status:", text, Date.now())
        }

        Text {
            id: indicator
            font {
                family: Fonts.sgicons
                pixelSize: 40
            }
            text: "\ue834"
            color: "#888"
            anchors {
                horizontalCenter: connectingStatus.horizontalCenter
                top: searchingText.bottom
                topMargin: 30
            }

            onVisibleChanged: {
                if(visible) {
                    indicatorAnimation.start()
                } else {
                    indicatorAnimation.stop();
                }
            }

            RotationAnimation on rotation {
                id: indicatorAnimation
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 750
                running: false
            }
        }
    }

    SequentialAnimation{
        //animator to show that the login failed
        id:failedLoginAnimation

        NumberAnimation {
            target: loginRectangle
            property: "height"
            to: 175
            duration: 200
        }
        NumberAnimation{
            target: loginErrorRect
            property:"opacity"
            to: 1
            duration: 200
        }
    }

    SequentialAnimation{
        //animator to show that the login failed
        id:hideFailedLoginAnimation

        NumberAnimation{
            target:loginErrorRect
            property:"opacity"
            to: 0
            duration: 200
        }

        NumberAnimation {
            target: loginRectangle
            property: "height"
            // Go back to original height
            to: 125
            duration: 200
        }

        onStopped: loginErrorText.text = ""
    }

    // These text boxes are HACK solution to get around an issue on windows builds where the glyphs loaded in this file were the ONLY glyphs that appeared in subsequent views.
    // the effects of this bug are documented here: https://bugreports.qt.io/browse/QTBUG-62578 - our instance of this issue was not random as described, however.  --Faller
    // Update 10/23/2018: This may have been solved by moving to singleton font loader, [TODO] need to test.
    Text {
        text: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890:./\\{}()[]-=+_!@#$%^&*`~<>?\"\'"
        font {
            family: Fonts.franklinGothicBold
        }
        visible: false
    }

    Text {
        text:  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890:./\\{}()[]-=+_!@#$%^&*`~<>?\"\'"
        font {
            family: Fonts.franklinGothicBook
        }
        visible: false
    }

    Text {
        text:  "\u0023 \u0027 \u0037 \u0038 \u003a \u0043 \u25b2 \ue800 \ue801 \ue805 \ue808 \ue80b \ue80e \ue810 \ue811 \ue813 \ue824 \ue834 \uf15b"
        font {
            family: Fonts.sgicons
        }
        visible: false
    }
}
