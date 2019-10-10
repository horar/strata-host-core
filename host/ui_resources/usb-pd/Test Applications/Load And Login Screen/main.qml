import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4

ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Load Screen")

    property var showLoginOnCompletion: false

    //determine which screen to show based on how the caller set the
    //showLoginOnCompletion property
    Component.onCompleted: {
        spotlightAnimation.start()
        if (showLoginOnCompletion){
            showConnectionScreen.start();
        }
    }

    //-----------------------------------------------------------
    //Elements common to both the connection and login screens
    //-----------------------------------------------------------
    Image {
        id: onLogo
        x: 281
        y: 94
        width: 80
        height: 80
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        source: "ONBall.svg"

    }


    Rectangle {
        id: spyglassTextRect
        x: 253
        y: 178
        width: 133
        height: 31
        color: "#ffffff"
        anchors { horizontalCenter: parent.horizontalCenter }

        Text {
            id: spyglassText1
            x: 0
            y: 0
            width: 14
            height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("s")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            anchors.horizontalCenterOffset: -40
        }

        Text {
            id: spyglassText2
            x: 11
            y: 0
            width: 18
            height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("p")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            anchors.horizontalCenterOffset: -26
        }

        Text {
            id: spyglassText3
            x: 82
            y: 0
            width: 14
            height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("y")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            anchors.horizontalCenterOffset: -14
        }


        Text {
            id: spyglassText4
            x: 91
            y: 0
            width: 14
            height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("g")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            anchors.horizontalCenterOffset: -2
        }

        Text {
            id: spyglassText5
            x: 77
            y: 0
            width: 12
            height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("l")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            anchors.horizontalCenterOffset: 11
        }

        Text {
            id: spyglassText6
            x: 77
            y: 0
            width: 14
            height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("a")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            anchors.horizontalCenterOffset: 17
        }

        Text {
            id: spyglassText7
            x: 74
            y: 0
            width: 14
            height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("s")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            anchors.horizontalCenterOffset: 30
        }

        Text {
            id: spyglassText8
            x: 83
            y: 0
            width: 14
            height: 31
            color: "#aeaeae"
            opacity: 0
            text: qsTr("s")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            anchors.horizontalCenterOffset: 41
        }
    }


    //-----------------------------------------------------------
    //connection screen elements
    //-----------------------------------------------------------
    Text {
        id: searchingText
        x: 217
        y: 213
        width: 147
        height: 15
        color: "#aeaeae"
        text: qsTr("Searching for hardware")
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 12
        opacity: 0
    }



    BusyIndicator {
        id: busyIndicator
        x: 301
        y: 264
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 8
        opacity:0
    }

    //-----------------------------------------------------------
    // login screen elements
    //-----------------------------------------------------------

    Rectangle {
        id: loginRectangle
        x: 225
        y: 213
        width: 200
        height: 149
        color: "#ffffff"
        border.color: "black"
        border.width: 1
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: headerBackground
            x: 1
            y: 1
            width: 198
            height: 29
            color: "#aeaeae"
        }

        Text {
            id: loginHeaderText
            x: 1
            y: 9
            width: 185
            height: 15
            color: "#ffffff"
            text: qsTr("login to your account")
            font.bold: true
            anchors.horizontalCenterOffset: 1
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 12
        }

        TextField {
            id: usernameField
            x: 8
            y: 36
            width: 184
            height: 28
            text: qsTr("username")
        }

        TextField {
            id: passwordField
            x: 8
            y: 75
            width: 184
            height: 28
            text: qsTr("password")
        }

        Button {
            id: loginButton
            x: 8
            y: 112
            width: 184
            height: 28
            text:"login"
            font.pointSize: 13
            font.bold: true

            contentItem: Text {
                text: loginButton.text
                font: loginButton.font
                opacity: enabled ? 1.0 : 0.3
                color: loginButton.down ? "white" : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }


            background: Rectangle {
                color: loginButton.down ? Qt.darker("#2eb457") : "#2eb457"
            }

            onClicked: {
                handleLoginClick.start();
            }
        }

    }

    Button {
        id: guestLoginButton
        x: 220
        y: 374
        width: 200
        height: 32
        text:"continue as guest"
        font.pointSize: 13
        font.bold: true
        anchors { horizontalCenter: parent.horizontalCenter }
        contentItem: Text {
            text: guestLoginButton.text
            font: guestLoginButton.font
            opacity: enabled ? 1.0 : 0.3
            color: guestLoginButton.down ? Qt.darker("#2eb457") : "#2eb457"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }


        background: Rectangle {
            //color: loginButton.down ? Qt.darker("#2eb457") : "#2eb457"
            border.width: 1
            border.color: "black"
        }

        onClicked: {
            handleLoginClick.start();
        }
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
                duration: 1000 }
            NumberAnimation{
                target: loginRectangle;
                property: "opacity";
                to: 0;
                duration: 1000 }
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
        property var fadeInTime: 1000
        property var fadeOutTime: 1000
        property var interLetterDelayTime: 500
    }

    ParallelAnimation{
        id: spotlightAnimation

        loops: Animation.Infinite // The animation is set to loop indefinitely
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
        PauseAnimation { duration: 4000 } // This puts a bit of time between the loop
    }















}
