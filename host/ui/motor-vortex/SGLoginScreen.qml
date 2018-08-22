import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Styles 1.4
import "js/navigation_control.js" as NavigationControl
import "js/login.js" as Authenticator
import "js/restclient.js" as Rest

Rectangle {
    id: container
    anchors { fill: parent }
    visible: true
    property bool showLoginOnCompletion: false
    clip: true

    Component.onCompleted: {
        //spotlightAnimation.start();
        if (showLoginOnCompletion){
            showConnectionScreen.start();
        }
        usernameField.forceActiveFocus();   //allows the user to type their username without clicking
    }

    // Login Button Connection
    Connections {
        target: loginButton
        onClicked: {
            // Report Error if we are missing text
            if (usernameField.text=="" || passwordField.text==""){
                failedLoginAnimation.start();
            }
            // Pass info to Authenticator
            var login_info = { user: usernameField.text, password: passwordField.text }
            Authenticator.login(login_info)
        }
    }

    Connections {
        target: Authenticator.signals
        onLoginResult: {
            console.log("Login result received")
            if(result){
                var data = { user_id: usernameField.text }
                NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT,data)
            }
            else{
                //Show the failed animation
                failedLoginAnimation.start()
            }
        }
        // [TODO][prasanth]: jwt will be created/received in the hcs
        // for now, jwt will be received in the UI and then sent to HCS
        onLoginJWT: {
            console.log("JWT received",jwt_string)
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
    //connection screen elements
    //-----------------------------------------------------------
    Text {
        id: searchingText
        x: 217; y: 213
        width: 147; height: 15
        color: "#aeaeae"
        text: qsTr("Searching for hardware")
        anchors {
            horizontalCenter: container.horizontalCenter
            top: spyglassTextRect.bottom
            topMargin: 25
        }
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        opacity: 0
    }

    BusyIndicator {
        id: busyIndicator
        x: 301; y: 264
        anchors {
            horizontalCenter: container.horizontalCenter
            top: searchingText.bottom
            topMargin: 25
        }
        font { pixelSize: 8 }
        opacity:0
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

        TextField {
            id: usernameField
            height: 38
            focus: true
            placeholderText: qsTr("Username")
            cursorPosition: 3
            anchors {
                top: loginRectangle.top
                left: loginRectangle.left
                right: loginRectangle.right
            }
            font {
                pixelSize: 15
                family: franklinGothicBook.name
            }
            background: Rectangle {
                border.color: usernameField.activeFocus ? "#219647" : "#ddd"
            }

            Keys.onPressed: {
                hideFailedLoginAnimation.start()
            }

            //handle a return key click, which is the equivalent of the login button being clicked
            Keys.onReturnPressed:{
                loginButton.clicked()
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
                family: franklinGothicBook.name
            }
            background: Rectangle {
                border.color: passwordField.activeFocus ? "#219647" : "#ddd"
            }

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
                    family: franklinGothicBold.name
                }
                wrapMode: Label.WordWrap
                anchors {
                    left: alertIcon.right
                    right: loginErrorRect.right
                    rightMargin: 5
                    verticalCenter: loginErrorRect.verticalCenter
                }
                horizontalAlignment:Text.AlignHCenter
                text: "Your username or password are incorrect"
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

            background: Rectangle {
                color: loginButton.down ? "#666" : "#888"
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
                    family: franklinGothicBold.name
                }
            }

            /* OnClicked is handled in Connections section above */
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
            target:loginErrorRect
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
    }

    SequentialAnimation{
        //animator to fade out the login elements and show the connection screen
        id:handleLoginClick
        running: false

        ParallelAnimation{
            NumberAnimation{
                target: loginRectangle;
                property: "opacity";
                to: 0;
                duration: 1000
            }
        }

        ParallelAnimation{
            //reveal the connection screen elements
            NumberAnimation{
                target: searchingText;
                property: "opacity";
                to: 1;
                duration: 1000
            }
            NumberAnimation{
                target: busyIndicator;
                property: "opacity";
                to: 1;
                duration: 1000
            }
        }
    }

    ParallelAnimation{
        id:showConnectionScreen
        running:false
        NumberAnimation{
            target: loginRectangle;
            property: "opacity";
            to: 0;
            duration: 1
        }
        //reveal the connection screen elements
        NumberAnimation{
            target: searchingText;
            property: "opacity";
            to: 1;
            duration: 1
        }
        NumberAnimation{
            target: busyIndicator;
            property: "opacity";
            to: 1;
            duration: 1
        }
    }

    FontLoader {
        id: franklinGothicBook
        source: "qrc:/fonts/FranklinGothicBook.otf"
    }

    FontLoader {
        id: franklinGothicBold
        source: "qrc:/fonts/FranklinGothicBold.ttf"
    }


    // These text boxes are HACK solution to get around an issue on windows builds where the glyphs loaded in this file were the ONLY glyphs that appeared in subsequent views.
    // the effects of this bug are documented here: https://bugreports.qt.io/browse/QTBUG-62578 - our instance of this issue was not random as described, however.  --Faller
    Text {
        text: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890:./\\{}()[]-=+_!@#$%^&*`~<>?\"\'"
        font {
            family: franklinGothicBold.name
        }
        visible: false
    }

    Text {
        text:  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890:./\\{}()[]-=+_!@#$%^&*`~<>?\"\'"
        font {
            family: franklinGothicBook.name
        }
        visible: false
    }
}
