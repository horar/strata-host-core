import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Styles 1.4
import tech.spyglass.ImplementationInterfaceBinding 1.0

Rectangle {
    id: parent
    visible: true
    property string titleName: "Encore Design Suite"

    //determine which screen to show based on how the caller set the
    //showLoginOnCompletion property
    property bool showLoginOnCompletion: false
    property int position : 10
    property int offset: 10
    property int letterHolder: -1
    property int animationHolder:0

    function getElement(element) {
        return element.itemAt(letterHolder);

    }

    function createObject() {
        console.log("Letter",  getElement(repeater).text );
        var dynamicObject = Qt.createQmlObject(
                    'import QtQuick 2.7; SequentialAnimation{ id: animation
               NumberAnimation { target: getElement(repeater) ; property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1500;}
                NumberAnimation { target: getElement(repeater); property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 4000;}
            }',
                    parent,'firstObject');
        dynamicObject.start();
        return dynamicObject;
    }



    function substring(str,start,end) {
        return str.substring(start, end);
    }
    function changePosition(){

        return position = position + offset;
    }

    function changeInterval(index) {
        return index * 500;
    }

    Component.onCompleted: {
        //spotlightAnimation.start();
        timerAnimation.start();
        if (showLoginOnCompletion){
            showConnectionScreen.start();
        }
        usernameField.forceActiveFocus();   //allows the user to type their username without clicking
    }

    Item {
        z: 2
        anchors { top: onLogo.bottom;
            horizontalCenter: parent.horizontalCenter;
            horizontalCenterOffset: -170
        }
        Repeater {
            id: repeater
            model: titleName.length

            Text{
                id: modelText
                color: "#aeaeae"
                opacity: 0
                width: 18; height: 31
                font.pixelSize: 24
                horizontalAlignment: Text.AlignLeft
                text: substring(titleName,index,index+1)
                Component.onCompleted: {x = changePosition();console.log("change position", changePosition())}
            }
        }
    }

    Timer {
        id: timerAnimation
        interval: 500;  running: true; repeat: true
        onTriggered: {

            if(letterHolder != titleName.length - 1)
            { letterHolder++; }
            else  { letterHolder = 0; }
            createObject();
        }

    }

    property bool  onIdChange : {

        onPlatformIdChanged: {

            // TODO[Abe]: Why does this property get called on stack changes?

            // If Logged in and platform is detected id: spotlightAnimation

            if ( !login_detected ) {
                // Keep showing the login screen; so do nothing
            }
            else if(login_detected ) {
                var platformId = implementationInterfaceBinding.Id;

                // Show the platform specific GUI
                switch (platformId) {
                case ImplementationInterfaceBinding.NONE:
                    console.log("Not recognizing new platform");
                    // Hide the toolbar; Comes back on platform detect
                    frontToolBar.visible = false;
                    stack.pop()
                    handleLoginClick.start();
                    break;
                case ImplementationInterfaceBinding.BUBU_INTERFACE:
                    console.log("Displaying BU Bring Up");
                    stack.push([boardBringUp, {immediate:false}]);
                    break;
                case ImplementationInterfaceBinding.USB_PD:
                    frontToolBar.visible = true
                    if(mainWindow.control_type == "standard") {
                        stack.pop();
                        stack.push([cBoardLayout, {immediate:false}]);
                    }
                    else if (mainWindow.control_type == "advanced") {
                        stack.pop();
                        stack.push([advanced, {immediate:false}]);
                    }
                    else if(mainWindow.control_type == "BuBu") {
                        stack.pop();
                        stack.push([boardBringUp, {immediate:false}]);

                    }

                    console.log("Displaying USB-PD");


                    break;
                }

            }
            console.log("stack depth:", stack.depth)
            return true;
        }
    }

    //-----------------------------------------------------------
    //Elements common to both the connection and login screens
    //-----------------------------------------------------------


    Image {
        id: onLogo
        width: 80; height: 80
        anchors{horizontalCenter: parent.horizontalCenter
            bottom:spyglassTextRect.top}
        source: "../images/icons/onLogoGrey.svg"
        mipmap: true;
    }
    Rectangle{
        id: spyglassTextRect
        //x: 253; y: 178
        width: 133; height: 31
        color: "#ffffff"
        anchors.horizontalCenterOffset: -7
        anchors { horizontalCenter: parent.horizontalCenter;
            verticalCenter: parent.verticalCenter;
            verticalCenterOffset: -72 }


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
            text: qsTr("login to your account")
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
            placeholderText: qsTr(" username")
            Material.accent: Material.Grey
            cursorPosition: 3
            font.pointSize: Qt.platform.os == "osx"? 13 :8

            //handle a return key click, which is the equivalent of the login button being clicked
            Keys.onReturnPressed:{
                if (usernameField.text=="" && passwordField.text==""){
                    failedLogin.start();
                }
                else{
                    login_detected = true;
                }
            }
        }

        TextField {
            id: passwordField
            x: 8; y: 75
            width: 184; height: 38
            activeFocusOnTab: true
            placeholderText: qsTr(" password")
            echoMode: TextInput.Password
            Material.accent: Material.Grey
            font.pointSize: Qt.platform.os == "osx"? 13 :8

            //handle a return key click, which is the equivalent of the login button being clicked
            Keys.onReturnPressed:{
                if (usernameField.text=="" && passwordField.text==""){
                    failedLogin.start();
                }
                else{
                    login_detected = true;
                }
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
                text: "Your username or password is incorrect"
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
            text:"login"
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

            onClicked: {

                if (usernameField.text=="" && passwordField.text==""){
                    failedLogin.start();
                }
                else{   //valid login
                    login_detected = true;
                }
            }

        }
    }



    Button {
        id: guestLoginButton
        width: 200; height: 32
        anchors{ horizontalCenter: parent.horizontalCenter;
            top: spyglassTextRect.bottom
            topMargin: 230}

        contentItem: Text {
            text:"continue as guest"
            opacity: enabled ? 1.0 : 0.3
            //the color of the content determines the button's text color
            color: guestLoginButton.down ? Qt.darker("#2eb457") : "#2eb457"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.pointSize: Qt.platform.os == "osx"? 15 :8
            font.bold: true
        }
        background: Rectangle {
            color: "white"
            border{ width: 1; color: "black" }
        }
        onClicked: {
            login_detected = true;

        }
    }

    Timer {
        id: myTime
        interval: 5000; running: guestLoginButton.pressed | loginButton.pressed ; repeat: false
        onTriggered:{ stack.pop() }

    }

    SequentialAnimation{
        //animator to show that the login failed
        id:failedLogin

        NumberAnimation {
            target: loginRectangle
            property: "height"
            to: 200
            duration: 700
        }
        NumberAnimation{
            target:loginErrorRect
            property:"opacity"
            to: 1
            duration: 700
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

    //    ParallelAnimation{
    //        //id: spotlightAnimation

    //        loops: Animation.Infinite// The animation is set to loop indefinitely
    //        SequentialAnimation{
    //            Component.onCompleted: { ;
    //                console.log(repeated.itemAt(3).text.toString());}
    //            NumberAnimation { target:repeated.itemAt(3); property: "opacity"; from: 0; to: 1; easing.type:Easing.OutInCubic; duration: 1000;}
    //            NumberAnimation { target: repeated.itemAt(3); property: "opacity"; from: 1; to: 0; easing.type:Easing.OutInCubic; duration: 500; }
    //        }
    //    }
    //       }
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
//}




