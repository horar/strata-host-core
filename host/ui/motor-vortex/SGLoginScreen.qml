import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Styles 1.4
import "js/navigation_control.js" as NavigationControl
import "js/login.js" as Authenticator
import "js/restclient.js" as Rest

Rectangle {
    anchors { fill: parent }
    visible: true
    property bool showLoginOnCompletion: false

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

    }

    //property bool  onIdChange :

    //-----------------------------------------------------------
    //Elements common to both the connection and login screens
    //-----------------------------------------------------------

    // PROOF OF CONCEPT BANNER
    Rectangle {
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        width: parent.width * 0.70; height: 30;
        color: "red"
        opacity: .8
        radius: 4
        Label {
            anchors { centerIn: parent }
            text: "SPYGLASS PROOF OF CONCEPT WITH LAB CLOUD"
            color: "white"
            font.pointSize: Qt.platform.os == "osx"? 13 :8
            font.bold: true
        }
    }

    Image {
        id: onLogo
        width: 80; height: 80
        anchors{horizontalCenter: parent.horizontalCenter
            bottom:spyglassTextRect.top}
        source: "../images/icons/onLogoGrey.svg"
        mipmap: true;
    }

    Rectangle {
        id: spyglassTextRect
        height: 31
        color: "#ffffff"
        anchors.horizontalCenterOffset: -45
        anchors { horizontalCenter: parent.horizontalCenter;
            verticalCenter: parent.verticalCenter;
            verticalCenterOffset: -97}
    }

        Label {
            width:text.fit
            height:50
            anchors { top: onLogo.bottom;
                topMargin: 10
                horizontalCenter: onLogo.horizontalCenter}
            z:2
            text: "Encore Design Suite"
            font.pointSize: Qt.platform.os == "osx"? 20 :16
            font.family:"helvetica"
            color:"lightGrey"
        }
   // }
    //        Text {
    //            id: spyglassText1
    //            x: 0; y: 0
    //            width: 14; height: 31
    //            color: "#aeaeae"
    //            opacity: 0
    //            text: qsTr("s")
    //            anchors{ horizontalCenter: parent.horizontalCenter;  horizontalCenterOffset: -40 }
    //            font{ pixelSize: 24 }
    //            horizontalAlignment: Text.AlignLeft
    //        }

    //        Text {
    //            id: spyglassText2
    //            x: 11; y: 0
    //            width: 18; height: 31
    //            color: "#aeaeae"
    //            opacity: 0
    //            text: qsTr("p")
    //            anchors{ horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: -26 }
    //            font.pixelSize: 24
    //            horizontalAlignment: Text.AlignLeft
    //        }

    //        Text {
    //            id: spyglassText3
    //            x: 82; y: 0
    //            width: 14; height: 31
    //            color: "#aeaeae"
    //            opacity: 0
    //            text: qsTr("y")
    //            anchors{ horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: -14 }
    //            font { pixelSize: 24 }
    //            horizontalAlignment: Text.AlignLeft
    //        }

    //        Text {
    //            id: spyglassText4
    //            x: 91; y: 0
    //            width: 14; height: 31
    //            color: "#aeaeae"
    //            opacity: 0
    //            text: qsTr("g")
    //            anchors { horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: -2 }
    //            font.pixelSize: 24
    //            horizontalAlignment: Text.AlignLeft
    //        }

    //        Text {
    //            id: spyglassText5
    //            x: 77; y: 0
    //            width: 12; height: 31
    //            color: "#aeaeae"
    //            opacity: 0
    //            text: qsTr("l")
    //            anchors { horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: 11 }
    //            font { pixelSize: 24 }
    //            horizontalAlignment: Text.AlignLeft
    //        }

    //        Text {
    //            id: spyglassText6
    //            x: 77;  y: 0
    //            width: 14; height: 31
    //            color: "#aeaeae"
    //            opacity: 0
    //            text: qsTr("a")
    //            anchors{ horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: 17 }
    //            font { pixelSize: 24 }
    //            horizontalAlignment: Text.AlignLeft
    //        }

    //        Text {
    //            id: spyglassText7
    //            x: 74; y: 0
    //            width: 14; height: 31
    //            color: "#aeaeae"
    //            opacity: 0
    //            text: qsTr("s")
    //            anchors{ horizontalCenter: parent.horizontalCenter;  horizontalCenterOffset: 30 }
    //            font { pixelSize: 24 }
    //            horizontalAlignment: Text.AlignLeft

    //        }

    //        Text {
    //            id: spyglassText8
    //            x: 83; y: 0
    //            width: 14; height: 31
    //            color: "#aeaeae"
    //            opacity: 0
    //            text: qsTr("s")
    //            anchors { horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: 41 }
    //            font { pixelSize: 24 }
    //            horizontalAlignment: Text.AlignLeft
    //        }
    //    }
    //-----------------------------------------------------------
    //connection screen elements
    //-----------------------------------------------------------
    Text {
        id: searchingText
        x: 217; y: 213
        width: 147; height: 15
        color: "#aeaeae"
        text: qsTr("Searching for hardware")
        anchors { horizontalCenter: parent.horizontalCenter
            top: spyglassTextRect.bottom
            topMargin: 25}
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        opacity: 0
    }
    BusyIndicator {
        id: busyIndicator
        x: 301; y: 264
        anchors {horizontalCenter: parent.horizontalCenter
            top: searchingText.bottom
            topMargin: 25}
        font { pixelSize: 8 }
        opacity:0
    }

    //-----------------------------------------------------------
    // login screen elements
    //-----------------------------------------------------------

    Rectangle {
        id: loginRectangle
        x: 225; y: 213
        width: 200; height: 150
        color: "#ffffff"
        border { color: "black"; width: 1 }
        anchors { horizontalCenter: parent.horizontalCenter;
            top: spyglassTextRect.bottom
            topMargin: 15}



        Rectangle {
            id: headerBackground
            x: 1; y: 1
            width: 198; height: 29
            color: "#aeaeae"
        }

        Text {
            id: loginHeaderText
            x: 1; y: 9
            width: 185; height: 15
            color: "#ffffff"
            text: qsTr("Login to your account")
            font { bold: true }
            font.pointSize: Qt.platform.os == "osx"? 13 :8
            anchors { horizontalCenterOffset: 1; horizontalCenter: parent.horizontalCenter }
            horizontalAlignment: Text.AlignHCenter
        }

        TextField {
            id: usernameField
            x: 8; y: 40
            width: 184; height: 38
            focus: true
            placeholderText: qsTr(" Username")
            Material.accent: Material.Grey
            cursorPosition: 3
            font.pointSize: Qt.platform.os == "osx"? 13 :8

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
            x: 8; y: 75
            width: 184; height: 38
            activeFocusOnTab: true
            placeholderText: qsTr(" Password")
            echoMode: TextInput.Password
            Material.accent: Material.Grey
            font.pointSize: Qt.platform.os == "osx"? 13 :8

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
            x:8; y:111
            width: 184; height:48
            color:"red"
            opacity: 0.0

            Image{
                id:alertIcon
                source: "./images/whiteAlertIcon.svg"
                anchors{left:parent.left; top:parent.top; bottom:parent.bottom
                    leftMargin: 5; topMargin:10; bottomMargin:10}
                fillMode:Image.PreserveAspectFit

                mipmap: true;
            }

            Text{
                id:loginErrorText
                font.family: "helvetica"
                font.bold:true
                font.pointSize: (Qt.platform.os == "osx") ? 13 : 8
                wrapMode: Label.WordWrap
                anchors {
                    left: alertIcon.right
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                horizontalAlignment:Text.AlignHCenter
                text: "Your username or password are incorrect"
                color: "white"
            }


        }

        Button {
            id: loginButton
            anchors{bottom:loginRectangle.bottom
                bottomMargin: 6
                left: loginRectangle.left
                leftMargin: 8}
            width: 184; height: 38
            text:"Login"
            Material.elevation: 6
            Material.background: loginButton.down ? Qt.darker("#2eb457") : "#2eb457"

            contentItem: Text {
                text: loginButton.text
                font.family: "helvetica"
                opacity: enabled ? 1.0 : 0.3
                color: loginButton.down ? "white" : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.pointSize: Qt.platform.os != "osx"? 10 :13
                font.bold:true
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
            to: 200
            duration: 500
        }
        NumberAnimation{
            target:loginErrorRect
            property:"opacity"
            to: 1
            duration: 500
        }
    }

    SequentialAnimation{
        //animator to show that the login failed
        id:hideFailedLoginAnimation

        NumberAnimation{
            target:loginErrorRect
            property:"opacity"
            to: 0
            duration: 500
        }

        NumberAnimation {
            target: loginRectangle
            property: "height"
            // Go back to original height
            to: 150
            duration: 500
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
                duration: 1000 }
            NumberAnimation{
                target: busyIndicator;
                property: "opacity";
                to: 1;
                duration: 1000 }
        }
    }

    ParallelAnimation{
        id:showConnectionScreen
        running:false
        NumberAnimation{
            target: loginRectangle;
            property: "opacity";
            to: 0;
            duration: 1 }
        //reveal the connection screen elements
        NumberAnimation{
            target: searchingText;
            property: "opacity";
            to: 1;
            duration: 1 }
        NumberAnimation{
            target: busyIndicator;
            property: "opacity";
            to: 1;
            duration: 1 }
    }

    Item{
        property int fadeInTime: 1000
        property int fadeOutTime: 1000
        property int interLetterDelayTime: 500
    }

    //    ParallelAnimation{
    //        id: spotlightAnimation

    //        loops: Animation.Infinite// The animation is set to loop indefinitely
    //        SequentialAnimation{
    //            NumberAnimation { target: spyglassText1; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
    //            NumberAnimation { target: spyglassText1; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
    //        }
    //        SequentialAnimation{
    //            PauseAnimation { duration: 250 }
    //            NumberAnimation { target: spyglassText2; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
    //            NumberAnimation { target: spyglassText2; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
    //        }
    //        SequentialAnimation{
    //            PauseAnimation { duration: 250*2 }
    //            NumberAnimation { target: spyglassText3; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
    //            NumberAnimation { target: spyglassText3; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
    //        }
    //        SequentialAnimation{
    //            PauseAnimation { duration: 250*3 }
    //            NumberAnimation { target: spyglassText4; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
    //            NumberAnimation { target: spyglassText4; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
    //        }
    //        SequentialAnimation{
    //            PauseAnimation { duration: 250*4 }
    //            NumberAnimation { target: spyglassText5; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
    //            NumberAnimation { target: spyglassText5; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
    //        }
    //        SequentialAnimation{
    //            PauseAnimation { duration: 250*5 }
    //            NumberAnimation { target: spyglassText6; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
    //            NumberAnimation { target: spyglassText6; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
    //        }
    //        SequentialAnimation{
    //            PauseAnimation { duration: 250*6 }
    //            NumberAnimation { target: spyglassText7; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
    //            NumberAnimation { target: spyglassText7; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
    //        }
    //        SequentialAnimation{
    //            PauseAnimation { duration: 250*7 }
    //            NumberAnimation { target: spyglassText8; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
    //            NumberAnimation { target: spyglassText8; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
    //        }
    //    }
}








