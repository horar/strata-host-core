import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import tech.spyglass.ImplementationInterfaceBinding 1.0

Rectangle {
    visible: true
    //determine which screen to show based on how the caller set the
    //showLoginOnCompletion property
    property bool showLoginOnCompletion: false
    property bool loginScreen: true

    Component.onCompleted: {
        spotlightAnimation.start();
        if (showLoginOnCompletion){
            showConnectionScreen.start();
        }
    }

    property bool  hardwareStatus : {
        var state = implementationInterfaceBinding.platformState;

        if(loginScreen==true) {
            if(state == true && login_detected == true){
                stack.pop();
                return
            }
        }
        else if (loginScreen == false) {

            if(state == false && login_detected == true){
            } else if(state == true && login_detected == true){
                stack.pop();
            } else if(state == false){
                handleLoginClick.start();

            }
        }
        implementationInterfaceBinding.platformState
    }

    //-----------------------------------------------------------
    //Elements common to both the connection and login screens
    //-----------------------------------------------------------

    // PROOF OF CONCEPT BANNER
    Rectangle {
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        width: parent.width * 0.70; height: 30;
        color: "red"
        radius: 4
        Label {
            anchors { centerIn: parent }
            text: "SPYGLASS PROOF OF CONCEPT WITH LAB CLOUD"
            color: "white"
            font.bold: true
        }
    }

    Image {
        id: onLogo
        width: 80; height: 80
        anchors{horizontalCenter: parent.horizontalCenter
            bottom:spyglassTextRect.top}
        source: "ONBall.svg"
        mipmap: true;
    }

    Rectangle {
        id: spyglassTextRect
        //x: 253; y: 178
        width: 133; height: 31
        color: "#ffffff"
        anchors { horizontalCenter: parent.horizontalCenter;
            verticalCenter: parent.verticalCenter;
            verticalCenterOffset: -100}

        Text {
            id: spyglassText1
            x: 0; y: 0
            width: 14; height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("s")
            anchors{ horizontalCenter: parent.horizontalCenter;  horizontalCenterOffset: -40 }
            font{ pixelSize: 24 }
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            id: spyglassText2
            x: 11; y: 0
            width: 18; height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("p")
            anchors{ horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: -26 }
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            id: spyglassText3
            x: 82; y: 0
            width: 14; height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("y")
            anchors{ horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: -14 }
            font { pixelSize: 24 }
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            id: spyglassText4
            x: 91; y: 0
            width: 14; height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("g")
            anchors { horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: -2 }
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            id: spyglassText5
            x: 77; y: 0
            width: 12; height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("l")
            anchors { horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: 11 }
            font { pixelSize: 24 }
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            id: spyglassText6
            x: 77;  y: 0
            width: 14; height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("a")
            anchors{ horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: 17 }
            font { pixelSize: 24 }
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            id: spyglassText7
            x: 74; y: 0
            width: 14; height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("s")
            anchors{ horizontalCenter: parent.horizontalCenter;  horizontalCenterOffset: 30 }
            font { pixelSize: 24 }
            horizontalAlignment: Text.AlignLeft

        }

        Text {
            id: spyglassText8
            x: 83; y: 0
            width: 14; height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("s")
            anchors { horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: 41 }
            font { pixelSize: 24 }
            horizontalAlignment: Text.AlignLeft
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
        width: 200; height: 149
        color: "#ffffff"
        border { color: "black"; width: 1 }
        anchors { horizontalCenter: parent.horizontalCenter;
            verticalCenter: parent.verticalCenter}

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
            text: qsTr("login to your account")
            font { bold: true }
            fontSizeMode: Text.Fit
            anchors { horizontalCenterOffset: 1; horizontalCenter: parent.horizontalCenter }
            horizontalAlignment: Text.AlignHCenter
        }

        TextField {
            id: usernameField
            x: 8; y: 36
            width: 184; height: 28
            placeholderText: qsTr("username")
        }

        TextField {
            id: passwordField
            x: 8; y: 75
            width: 184; height: 28
            placeholderText: qsTr("password")
            echoMode: TextInput.Password
        }

        Button {
            id: loginButton
            x: 8; y: 112
            width: 184; height: 28
            text:"login"
            font{ pointSize: 13; bold: true }

            contentItem: Text {
                text: loginButton.text
                font: loginButton.font
                opacity: enabled ? 1.0 : 0.3
                color: loginButton.down ? "white" : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                fontSizeMode: Qt.platform.os != "osx"? 8 :Text.Fit
            }

            background: Rectangle {
                color: loginButton.down ? Qt.darker("#2eb457") : "#2eb457"
            }

            onClicked: {
                loginScreen = false;
                login_detected = true;
            }
        }
    }

    //handle a return key click, which is the equivalent of the login button being clicked
    Keys.onReturnPressed:{
        loginScreen = false;
        login_detected = true;
    }

    Button {
        id: guestLoginButton
        width: 200; height: 32
        font{ pointSize: 13; bold: true;}
        anchors{ horizontalCenter: parent.horizontalCenter;
            top: loginRectangle.bottom
            topMargin: 25}

        contentItem: Text {
            text:"continue as guest"
            opacity: enabled ? 1.0 : 0.3
            //the color of the content determines the button's text color
            color: guestLoginButton.down ? Qt.darker("#2eb457") : "#2eb457"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            fontSizeMode: Qt.platform.os != "osx"? 8 :Text.Fit
        }
        background: Rectangle {
            color: "white"
            border{ width: 1; color: "black" }
        }
        onClicked: {
            loginScreen = false;
            login_detected = true;

        }
    }

    Timer {
        id: myTime
        interval: 5000; running: guestLoginButton.pressed | loginButton.pressed ; repeat: false
        onTriggered:{ stack.pop() }

    }

    SequentialAnimation{
        //animator to fade out the login elements and show the connection screen
        id:handleLoginClick
        running: false

        ParallelAnimation{
            NumberAnimation{
                target: guestLoginButton;
                property: "opacity";
                to: 0;
                duration: 1000
            }
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
            target: guestLoginButton;
            property: "opacity";
            to: 0;
            duration: 1 }
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

    ParallelAnimation{
        id: spotlightAnimation

        loops: Animation.Infinite// The animation is set to loop indefinitely
        SequentialAnimation{
            NumberAnimation { target: spyglassText1; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
            NumberAnimation { target: spyglassText1; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
        }
        SequentialAnimation{
            PauseAnimation { duration: 250 }
            NumberAnimation { target: spyglassText2; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
            NumberAnimation { target: spyglassText2; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
        }
        SequentialAnimation{
            PauseAnimation { duration: 250*2 }
            NumberAnimation { target: spyglassText3; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
            NumberAnimation { target: spyglassText3; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
        }
        SequentialAnimation{
            PauseAnimation { duration: 250*3 }
            NumberAnimation { target: spyglassText4; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
            NumberAnimation { target: spyglassText4; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
        }
        SequentialAnimation{
            PauseAnimation { duration: 250*4 }
            NumberAnimation { target: spyglassText5; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
            NumberAnimation { target: spyglassText5; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
        }
        SequentialAnimation{
            PauseAnimation { duration: 250*5 }
            NumberAnimation { target: spyglassText6; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
            NumberAnimation { target: spyglassText6; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
        }
        SequentialAnimation{
            PauseAnimation { duration: 250*6 }
            NumberAnimation { target: spyglassText7; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
            NumberAnimation { target: spyglassText7; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
        }
        SequentialAnimation{
            PauseAnimation { duration: 250*7 }
            NumberAnimation { target: spyglassText8; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000; }
            NumberAnimation { target: spyglassText8; property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
        }
    }
}



