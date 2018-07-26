import QtQuick 2.10 // to support scale animator
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Window 2.3 // for debug window, can be cut out for release
import "js/navigation_control.js" as NavigationControl
import "qrc:/statusbar-partial-views"

Rectangle {
    id: container
    anchors.fill: parent

    // Context properties that get passed when created dynamically
    property string user_id: ""
    property bool is_logged_in: false
    property string generalTitle: "Guest"
    property color backgroundColor: "#3a3a3a"

    color: backgroundColor

    function getWidth(string) {
        return (string.match(/width=\"([0-9]+)\"/))
    }

    function getHeight(string) {
        return (string.match(/height=\"([0-9]+)\"/))
    }

    property var userImages: {
        "dave.priscak@onsemi.com" : "dave_priscak.png",
                "david.somo@onsemi.com" : "david_somo.png",
                "daryl.ostrander@onsemi.com" : "daryl_ostrander.png",
                "paul.mascarenas@onsemi.com" : "paul_mascarenas.png",
                "ian.cain@onsemi.com" : "ian.cain.jpg",
                "blankavatar" : "blank_avatar.png"
    }

    property var userNames: {
        "dave.priscak@onsemi.com" : "Dave Priscak",
                "david.somo@onsemi.com"   : "David Somo",
                "daryl.ostrander@onsemi.com" : "Daryl Ostrander",
                "paul.mascarenas@onsemi.com" : "Paul Mascarenas",
                "ian.cain@onsemi.com" : "Ian Cain"
    }

    property var userJobtitle: {
        "dave.priscak@onsemi.com" : "VP Solutions Engineering",
                "david.somo@onsemi.com"   : "Vice President, Corporate Strategy and Marketing",
                "daryl.ostrander@onsemi.com" : "Director ON Semiconductor",
                "paul.mascarenas@onsemi.com" : "Director ON Semiconductor",
                "ian.cain@onsemi.com" : "Corporate Tech Ladder-Apps Mgmt (TL)"
    }

    function getUserImage(user_name){
        user_name = user_name.toLowerCase()
        if(userImages.hasOwnProperty(user_name)){
            return userImages[user_name]
        }
        else{
            return userImages["blankavatar"]
        }
    }

    function getUserName(user_name){
        var user_lower = user_name.toLowerCase()
        if(userNames.hasOwnProperty(user_lower)){
            return userNames[user_lower]
        }
        else{
            return user_name
        }
    }

    function getJobTitle(user_name){
        var user_lower = user_name.toLowerCase()
        if(userJobtitle.hasOwnProperty(user_lower)){
            return userJobtitle[user_lower]
        }
        else{
            return generalTitle;
        }

    }

    function generateToken(n) {
        var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        var token = '';
        for(var i = 0; i < n; i++) {
            token += chars[Math.floor(Math.random() * chars.length)];
        }
        return token;
    }

    function find(model, remote_user_name) {
        for(var i = 0; i < model.count; ++i) {
            if (remote_user_name === model.get(i).name) {
                return i
            }
        }
        return null
    }

//    Popup {
//        id: remoteSupportConnect
//        x: 400; y: 200
//        width: 400; height: 200
//        modal: true
//        focus: true
//        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

//        onOpened: {
//            console.log("opened!")
//        }

//        // Connections for internal event handling
//        Connections{
//            target: submitTokenButton
//            onClicked: {
//                // Send command to CoreInterface
//                // Go to connecting
//                remoteConnectContainer.state = "connecting"
//            }
//        }

//        Connections{
//            target: tokenBusyTimer
//            onTriggered: {
//                remoteConnectContainer.state = "timeout"
//            }
//        }

//        Connections {
//            target: tryAgainButton
//            onClicked: {
//                remoteConnectContainer.state = "default"
//            }
//        }
//        Connections {
//            target: disconnectButton
//            onClicked: {
//                remoteConnectContainer.state = "default"
//                // sending remote disconnect message to hcs
//                var remote_disconnect_json = {
//                    "hcs::cmd":"remote_disconnect",
//                }
//                coreInterface.sendCommand(JSON.stringify(remote_disconnect_json))
//                console.log("UI -> HCS ", JSON.stringify(remote_disconnect_json));
//            }
//        }
//        Connections {
//            target: coreInterface
//            onPlatformStateChanged: {
//                remoteConnectContainer.state = "default"
//            }
//        }

//        Connections {
//            target: coreInterface
//            onRemoteConnectionChanged:{
//                if ( remoteConnectContainer.state === "connecting") {

//                    // Successful remote connection
//                    if (result === true){
//                        remoteConnectContainer.state = "success"
//                    }
//                    else {
//                        remoteConnectContainer.state = "error"
//                    }
//                }
//            }
//        }

//        Rectangle {
//            id: remoteConnectContainer
//            anchors.fill: parent
//            state: "default"
//            states: [
//                State {
//                    name: "default"
//                    // Show button and textfield
//                    PropertyChanges { target: tokenLabel; text: "Enter remote token"; visible: true}
//                    PropertyChanges { target: tokenInput; visible: true}
//                    PropertyChanges { target: tokenBusyIndicator; visible: false}
//                    PropertyChanges { target: tryAgainButton; visible: false }
//                    PropertyChanges { target: disconnectButton; visible: false}
//                },
//                State {
//                    name: "connecting"
//                    // Show BusyIndicator and 'connecting' text
//                    PropertyChanges { target: tokenLabel; text: "Attempting to connect to server"; visible: true}
//                    PropertyChanges { target: tokenBusyIndicator; visible: true}

//                    // Hide input
//                    PropertyChanges { target: tokenInput; visible: false}

//                    // Start timer
//                    PropertyChanges { target: tokenBusyTimer; running: true;}
//                },
//                State {
//                    name: "timeout"
//                    // Show timeout
//                    PropertyChanges { target: tokenLabel; text: "Connection to server timed out"; visible: true}
//                    PropertyChanges { target: statusImage; source: "qrc:/images/icons/fail_x.svg"; visible: true}

//                    // Hide BusyIndicator
//                    PropertyChanges { target: tokenBusyIndicator; visible: false}

//                    // Show button to try again
//                    PropertyChanges { target: tryAgainButton; visible: true }
//                },
//                State {
//                    name: "success"
//                    // Show timeout
//                    PropertyChanges { target: tokenLabel; text: "Connection successful. Remote device listed."; visible: true}
//                    PropertyChanges { target: statusImage; source: "qrc:/images/icons/success_check.svg"; visible: true}

//                    // Hide BusyIndicator
//                    PropertyChanges { target: tokenBusyIndicator; visible: false}

//                    // Show Disconnect
//                    PropertyChanges { target: disconnectButton; visible: true}

//                },

//                State {
//                    name: "error"
//                    // Show error
//                    PropertyChanges { target: tokenLabel; text: "Error with server connection"; visible: true}
//                    PropertyChanges { target: statusImage; source: "qrc:/images/icons/fail_x.svg"; visible: true}

//                    // Hide BusyIndicator
//                    PropertyChanges { target: tokenBusyIndicator; visible: false}

//                    // Show button to try again
//                    PropertyChanges { target: tryAgainButton; visible: true }
//                }

//            ]

//            // Timer to timeout busy animation
//            Timer {
//                // 3 second timeout for response
//                id: tokenBusyTimer
//                interval: 3000
//                running: false
//                repeat: false
//                onTriggered: {
//                    // Show failure
//                }
//            }

//            ColumnLayout{
//                anchors.fill: parent

//                spacing: 2
//                // Show busy
//                Rectangle {
//                    Layout.alignment: Qt.AlignTop
//                    width: tokenBusyIndicator.width
//                    height: tokenBusyIndicator.height
//                    anchors.horizontalCenter: parent.horizontalCenter

//                    BusyIndicator {
//                        id: tokenBusyIndicator
//                        // Bind to Timer
//                        running: tokenBusyTimer.running
//                        anchors.fill: parent
//                    }

//                    Image{
//                        id: statusImage
//                        width: parent.width
//                        height: parent.height
//                        fillMode: Image.PreserveAspectFit
//                        source: ""
//                    }
//                }

//                Label {
//                    id: tokenLabel
//                    height: 30
//                    text: "Enter remote token"
//                    font.pointSize: 15
//                    font.bold: true
//                    color: "dark blue"
//                    Layout.alignment: Qt.AlignCenter
//                }
//                Button {
//                    id: tryAgainButton
//                    text: "Try Again"
//                    Layout.alignment: Qt.AlignCenter
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    visible: false
//                }
//                Button {
//                    id: disconnectButton
//                    text: "Disconnect"
//                    Layout.alignment: Qt.AlignCenter
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    visible: false
//                }

//                Rectangle{
//                    id: tokenInput
//                    width: 300
//                    height: 50
//                    // Default visibility is false; state changes will make it visible
//                    visible: { console.log("created"); return false}

//                    Layout.alignment: Qt.AlignBottom
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    TextField {
//                        id: tokenField
//                        width: 184; height: 38
//                        selectByMouse: true
//                        focus: true
//                        placeholderText: qsTr("TOKEN")
//                        cursorPosition: 1
//                        font.pointSize: Qt.platform.os == "osx"? 13 :8
//                        Keys.onReturnPressed:{
//                            console.log("TOKEN: ", text);
//                        }
//                    }
//                    Button{
//                        id: submitTokenButton
//                        text: "Submit"
//                        width: 80; height: 38
//                        anchors{
//                            left:tokenField.right
//                        }
//                        onClicked: {
//                            console.log("sending token:", tokenField.text);
//                            var remote_json = {
//                                "hcs::cmd":"get_platforms",
//                                "payload": {
//                                    "hcs_token":tokenField.text
//                                }
//                            }
//                            coreInterface.sendCommand(JSON.stringify(remote_json))
//                            console.log("UI -> HCS ", JSON.stringify(remote_json));
//                        }

//                    }
//                }

//            }
//        }
//    }


    ///////////////////////////////////// moved to remoteinvitecontainer
//    Popup {
//        id: remoteSupportRequest
//        x: 400; y: 200
//        width: 400; height: 400
//        modal: true
//        focus: true
//        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

//        Rectangle{
//            id:advertiseButton;
//            width: 100;
//            height: 100;
//            anchors {
//                horizontalCenter: parent.horizontalCenter
//                margins: 30
//            }
//            property bool checked: false
//            border.color: "black";
//            border.width: 2;
//            color: advertiseButton.checked ? "lightgreen":"lightgrey"
//            Image{
//                id:remoteButtonImage
//                source: "qrc:/images/icons/remotecommunication.svg"
//                height: advertiseButton.height
//                width: advertiseButton.width
//            }
//            ScaleAnimator {
//                id: increaseOnMouseEnter
//                target: advertiseButton;
//                from: 1;
//                to: 1.2;
//                duration: 200
//                running: false
//            }
//            ScaleAnimator {
//                id: decreaseOnMouseExit
//                target: advertiseButton;
//                from: 1.2;
//                to: 1;
//                duration: 200
//                running: false
//            }
//            MouseArea {
//                id: imageMouse
//                anchors.fill: advertiseButton
//                hoverEnabled: true
//                cursorShape: Qt.PointingHandCursor
//                onEntered:{
//                    increaseOnMouseEnter.start()
//                }
//                onExited:{
//                    decreaseOnMouseExit.start()
//                }
//                onClicked: {
//                    advertiseButton.checked = !advertiseButton.checked
//                    var advertise
//                    if(advertiseButton.checked) {
//                        advertise = true
//                    }
//                    else {
//                        advertise = false
//                        remote_activity_label.visible = false
//                        remote_user_container.visible = false
//                        remote_user_label.visible = false
//                        remoteUserModel.clear()
//                    }
//                    var remote_json = {
//                        "hcs::cmd":"advertise",
//                        "payload": {
//                            "advertise_platforms":advertise
//                        }
//                    }
//                    console.log("asking hcs to advertise the platforms",JSON.stringify(remote_json))
//                    coreInterface.sendCommand(JSON.stringify(remote_json))
//                }
//            }
//        }

//        Label {
//            id: supportPhoneNumber
//            anchors {
//                top: advertiseButton.bottom
//                horizontalCenter: parent.horizontalCenter
//                margins: 30
//            }
//            text: advertiseButton.checked ? "click the button to turn off remote control":"click the button to turn on remote control"
//            font.pointSize: Qt.platform.os == "osx"? 13 :8
//            font.bold: true
//            color: "black"
//        }

//        Label {
//            id: hcs_token
//            anchors {
//                top: supportPhoneNumber.bottom
//                horizontalCenter: parent.horizontalCenter
//                margins: 30
//            }
//            text: advertiseButton.checked ? coreInterface.hcs_token_:""
//            font.pointSize: Qt.platform.os == "osx"? 13 :8
//            font.bold: true
//            color: "black"
//        }
//        Connections {
//            target: coreInterface
//            onPlatformStateChanged: {
//                remoteButton.checked = false
//            }
//        }
//    }


    //////////////////////////////////// moved to remoteInviteRight
//    Label {
//        id:remote_user_label
//        anchors {
//            left: toolBar.right
//            verticalCenter: container.verticalCenter;
//            verticalCenterOffset: 10
//        }

//        height: parent.height
//        text:  "Remote User/s:"
//        font.pointSize: Qt.platform.os == "osx"? 13 :8
//        font.bold: true
//        color: "white"
//        visible: false
//    }

//    ListModel {
//        id: remoteUserModel
//    }

//    Rectangle {
//        id: remote_user_container
//        anchors {
//            left: remote_user_label.right
//            leftMargin: 10
//        }
//        height: parent.height
//        width: parent.width*0.25
//        visible:false
//        color: container.backgroundColor
//        Component {
//            id: remoteUserDelegate
//            Item {
//                width: remote_user_container.width*0.1
//                height: remote_user_container.height
//                Rectangle{
//                    Image {
//                        id: remote_user_img
//                        anchors {
//                            horizontalCenter: parent.horizontalCenter
//                        }

//                        sourceSize.width: 1024;
//                        height: remote_user_container.height*.7
//                        fillMode: Image.PreserveAspectFit
//                        source: "qrc:/images/blank_avatar.png"
//                        Image {
//                            id: close_icon
//                            anchors {
//                                top: parent.top
//                                left: parent.left
//                            }
//                            height: parent.height*0.5
//                            width:parent.width*0.5
//                            fillMode: Image.PreserveAspectFit
//                            source: "qrc:/images/closeIcon.svg"
//                            visible: false
//                        }
//                        MouseArea {
//                            anchors.fill: remote_user_img
//                            hoverEnabled: true
//                            onEntered: { close_icon.visible = true }
//                            onExited: { close_icon.visible = false }
//                            onClicked: {
//                                var remote_json = {
//                                    "hcs::cmd":"disconnect_remote_user",
//                                    "payload": {
//                                        "user_name":name
//                                    }
//                                }
//                                console.log("disconnecting user",JSON.stringify(remote_json))
//                                coreInterface.sendCommand(JSON.stringify(remote_json))
//                                //                                    remoteUserModel.remove(remote_user_list_view.currentIndex,1)
//                            }
//                        }
//                    }
//                    Label {
//                        id:remote_user_name
//                        anchors {
//                            top: remote_user_img.bottom
//                            horizontalCenter: parent.horizontalCenter;
//                        }
//                        text:  name
//                        font.pointSize: Qt.platform.os == "osx"? 13 :8
//                        font.bold: true
//                        color: "white"
//                    }
//                }
//            }
//        }
//        ListView {
//            id: remote_user_list_view
//            anchors.fill: remote_user_container
//            model: remoteUserModel
//            delegate: remoteUserDelegate
//            orientation: ListView.Horizontal
//            focus: true
//        }
//    }

    Connections {
        target: coreInterface
        onRemoteUserAdded: {
            remoteUserModel.append({"name":user_name, "active":false})
        }
    }

    Connections {
        target: coreInterface
        onRemoteUserRemoved: {
            remoteUserModel.remove(find(remoteUserModel, user_disconnected))
        }
    }

    Connections {
        target: coreInterface
        onPlatformStateChanged: {
            tokenField.text = "";
            // send "close remote advertise to hcs to close the remote socket"
            if (remoteToggle.checked) {
                remoteToggle.checked = false;
                var remote_json = {
                    "hcs::cmd":"advertise",
                    "payload": {
                        "advertise_platforms":false
                    }
                }
                console.log("asking hcs to advertise the platforms",JSON.stringify(remote_json))
                coreInterface.sendCommand(JSON.stringify(remote_json))
            }
        }
    }

    Text {
        id: remote_activity_icon
        text: qsTr("\u0027")
        anchors {
            left: toolBar.right
            leftMargin: 15
            verticalCenter: container.verticalCenter
        }
        color: "#00b842"
        font {
            family: sgicons.name
            pixelSize: 20
        }
        visible: remote_activity_label.visible
    }

    Label {
        id:remote_activity_label
        anchors {
            left: remote_activity_icon.right
            leftMargin: 10
            verticalCenter: container.verticalCenter
        }
        text: ""
        visible: false
        color: "white"
    }


    Connections {
        target: coreInterface
        onRemoteActivityChanged: {
            remote_activity_label.visible = true;
            remote_activity_label.text= "Controlled by "+ coreInterface.remote_user_activity_;
            activityMonitorTimer.start();
        }
    }

    Timer {
        // 3 second timeout for response
        id: activityMonitorTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            remote_activity_label.visible = false;
        }
    }

    ToolBar {
        id: toolBar
        anchors {
            left: container.left
        }
        background: Rectangle {
            color: container.color
            height: container.height
        }

        Row {
            SGToolButton {
                id: platformOptionsButton
                text: qsTr("Platform Options")
                width: 150
                onPressed: {
                    platformOptionsMenu.open()
                }
                buttonColor: platformOptionsButton.hovered || platformOptionsMenu.visible ? Qt.lighter(container.color) : container.color


                Popup {
                    id: platformOptionsMenu
                    y: platformOptionsButton.height
                    padding: 0
                    width: 170
                    height: 80
                    background: Rectangle {
                        color: container.color
                        border {
                            width: 0
                        }
                    }

                    contentItem: Column {
                        id: platMenuColumn
                        width: platMenuColumn.width

                        SGMenuItem {
                            text: NavigationControl.flipable_parent_.flipped === true ? qsTr("View Platform Controls") : qsTr("View Platform Content")
                            onClicked: {
                                platformOptionsMenu.close()
                                NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
                            }
                            width: parent.width
                            buttonColor: !this.hovered ? container.color : this.pressed ? Qt.lighter(container.color, 2) : Qt.lighter(container.color)
                        }

                        SGMenuItem {
                            text: qsTr("Select Another Platform")
                            onClicked: {
                                platformOptionsMenu.close()
                            }
                            width: parent.width
                            buttonColor: !this.hovered ? container.color : this.pressed ? Qt.lighter(container.color, 2) : Qt.lighter(container.color)
                        }
                    }
                }
            }

            SGToolButton {
                id: remoteSupportButton
                text: qsTr("Remote Support")
                width: 150
                onPressed: {
                    remoteSupportMenu.open()
                }
                buttonColor: remoteSupportButton.hovered || remoteSupportMenu.visible ? Qt.lighter(container.color) : container.color

                Popup {
                    id: remoteSupportMenu
                    y: remoteSupportButton.height
                    padding: 0
                    width: 500
                    height: 250

                    background: Rectangle {
                        color: Qt.lighter(container.color)
                        border {
                            width: 0
                        }
                    }

                    contentItem: Item {
                        id: remoteMenuContent
                        width: remoteSupportMenu.width
                        height: remoteSupportMenu.height

                        TabBar {
                            id: remoteMenuSelector
                            width: remoteMenuContent.width
                            background: Rectangle {
                                color: "black"
                            }

                            SGTabButton {
                                text: qsTr("Invite to Connect")
                                onClicked: {
                                    remoteInviteContainer.visible = true
                                    remoteConnectContainer.visible = false
                                }
                                buttonColor: checked ? Qt.lighter(container.color) : container.color
                            }

                            SGTabButton {
                                text: qsTr("Connect to Remote")
                                onClicked: {
                                    remoteInviteContainer.visible = false
                                    remoteConnectContainer.visible = true
                                }
                                buttonColor: checked ? Qt.lighter(container.color) : container.color
                                enabled: !remoteToggle.checked
                            }
                        }

                        Item {
                            id: remoteInviteContainer
                            anchors {
                                top: remoteMenuSelector.bottom
                                bottom: remoteMenuContent.bottom
                                right: remoteMenuContent.right
                                left: remoteMenuContent.left
                            }
                            width: remoteMenuContent.width
                            visible: true

                            Item {
                                id: remoteInviteLeft
                                width: 270
                                anchors {
                                    margins: 15
                                    top: parent.top
                                    bottom: parent.bottom
                                    left: parent.left
                                }

                                Image {
                                    id: remoteImage
                                    source: remoteToggle.checked ? "qrc:/images/icons/remote-unlocked.png" : "qrc:/images/icons/remote-locked.png"
                                    anchors {
                                        horizontalCenter: parent.horizontalCenter
                                        top: parent.top
                                    }
                                }

                                SGSwitch {
                                    id: remoteToggle
                                    anchors {
                                        top: remoteImage.bottom
                                        topMargin: 15
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    label: "Remote Support Access:"
                                    labelLeft: true
                                    checkedLabel: "Enabled"
                                    uncheckedLabel: "Disabled"
                                    labelsInside: true
                                    switchWidth: 77
                                    textColor: "white"
                                    grooveFillColor: "#00b842"
                                    grooveColor: "#777"

                                    onCheckedChanged: {
                                        var advertise
                                        if(remoteToggle.checked) {
                                            advertise = true
                                        }
                                        else {
                                            advertise = false
                                            remoteUserModel.clear()
                                        }
                                        var remote_json = {
                                            "hcs::cmd":"advertise",
                                            "payload": {
                                                "advertise_platforms":advertise
                                            }
                                        }
                                        console.log("asking hcs to advertise the platforms",JSON.stringify(remote_json))
                                        coreInterface.sendCommand(JSON.stringify(remote_json))
                                    }
                                }

                                Label {
                                    id: hcs_token
                                    anchors {
                                        top: remoteToggle.bottom
                                        horizontalCenter: parent.horizontalCenter
                                        topMargin: 25
                                    }
                                    text: remoteToggle.checked ? "Your remote token is: " + coreInterface.hcs_token_ : "Enable to generate remote token"
                                    font {
                                        family: franklinGothicBook.name
                                    }
                                    color: "white"
                                }

                                Connections {
                                    target: coreInterface
                                    onPlatformStateChanged: {
                                        remoteToggle.checked = false
                                    }
                                }
                            }

                            Item {
                                id: remoteInviteRight
                                anchors {
                                    left: remoteInviteLeft.right
                                    top: parent.top
                                    bottom: parent.bottom
                                    right: parent.right
                                    leftMargin: 15
                                    topMargin: 10
                                    rightMargin: 5
                                }

                                Rectangle {
                                    id: connectedUsersTitle
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: parent.top
                                    }
                                    height: 30
                                    color: remoteToggle.checked ? Qt.darker(container.color, 1.25) : container.color

                                    Text {
                                        id: name
                                        text: qsTr("Connected Users:")
                                        anchors {
                                            verticalCenter: parent.verticalCenter
                                            left: parent.left
                                            leftMargin: 10
                                            verticalCenterOffset: 2
                                        }
                                        color: remoteToggle.checked ? "white" : "grey"
                                        font {
                                            family: franklinGothicBook.name
                                        }
                                    }
                                }

                                Rectangle {
                                    id: connectedUsersContainer
                                    color: remoteToggle.checked ? container.color : Qt.lighter(container.color, 1.25)
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: connectedUsersTitle.bottom
                                        topMargin: 2
                                        bottom: parent.bottom
                                        bottomMargin: 10
                                    }

                                    ListModel {
                                        id: remoteUserModel
                                    }

                                    Component {
                                        id: remoteUserDelegate

                                        Item {
                                            width: connectedUsersContainer.width
                                            height: 50

                                            Image {
                                                id: remote_user_img
                                                anchors {
                                                    left: parent.left
                                                    top: parent.top
                                                    leftMargin: 4
                                                    topMargin: 4
                                                }
                                                sourceSize.width: 1024;
                                                height: 46
                                                fillMode: Image.PreserveAspectFit
                                                source: "qrc:/images/blank_avatar.png"
                                            }

                                            Label {
                                                id:remote_user_name
                                                anchors {
                                                    left: remote_user_img.right
                                                    verticalCenter: parent.verticalCenter
                                                    leftMargin: 10
                                                    right: close_icon.left
                                                }
                                                text: name
                                                font {
                                                    family: franklinGothicBold.name
                                                }
                                                color: "white"
                                                elide: Text.ElideRight
                                            }

                                            Image {
                                                id: close_icon
                                                anchors {
                                                    verticalCenter: parent.verticalCenter
                                                    right: parent.right
                                                    rightMargin: 5
                                                }
                                                height: parent.height - 30
                                                width: height
                                                fillMode: Image.PreserveAspectFit
                                                source: "qrc:/images/closeIcon.svg"
                                            }

                                            MouseArea {
                                                anchors {
                                                    fill: close_icon
                                                }
                                                hoverEnabled: true
                                                onClicked: {
                                                    var remote_json = {
                                                        "hcs::cmd":"disconnect_remote_user",
                                                        "payload": {
                                                            "user_name":name
                                                        }
                                                    }
                                                    console.log("disconnecting user",JSON.stringify(remote_json))
                                                    coreInterface.sendCommand(JSON.stringify(remote_json))
                                                    //  remoteUserModel.remove(remote_user_list_view.currentIndex,1)
                                                }
                                                cursorShape: Qt.PointingHandCursor
                                            }
                                        }
                                    }

                                    ListView {
                                        id: remote_user_list_view
                                        anchors {
                                            fill: connectedUsersContainer
                                        }
                                        model: remoteUserModel
                                        delegate: remoteUserDelegate
                                        focus: true
                                        clip: true
                                    }
                                }
                            }
                        }

                        Item {
                            id: remoteConnectContainer
                            anchors {
                                top: remoteMenuSelector.bottom
                                bottom: remoteMenuContent.bottom
                            }
                            width: remoteMenuContent.width
                            visible: false

                            state: "default"
                            states: [
                                State {
                                    name: "default"
                                    // Show button and textfield
                                    PropertyChanges { target: tokenLabel; text: "Enter remote token:"; visible: true}
                                    PropertyChanges { target: tokenInput; visible: true}
                                    PropertyChanges { target: tokenBusyIndicator; visible: false}
                                    PropertyChanges { target: tryAgainButton; visible: false }
                                    PropertyChanges { target: disconnectButton; visible: false}
                                },
                                State {
                                    name: "connecting"
                                    // Show BusyIndicator and 'connecting' text
                                    PropertyChanges { target: tokenLabel; text: "Attempting to connect to server"; visible: true}
                                    PropertyChanges { target: tokenBusyIndicator; visible: true}

                                    // Hide input
                                    PropertyChanges { target: tokenInput; visible: false}

                                    // Start timer
                                    PropertyChanges { target: tokenBusyTimer; running: true;}
                                },
                                State {
                                    name: "timeout"
                                    // Show timeout
                                    PropertyChanges { target: tokenLabel; text: "Connection to server timed out"; visible: true}
                                    PropertyChanges { target: statusImage; source: "qrc:/images/icons/fail_x.svg"; visible: true}

                                    // Hide BusyIndicator
                                    PropertyChanges { target: tokenBusyIndicator; visible: false}

                                    // Show button to try again
                                    PropertyChanges { target: tryAgainButton; visible: true }
                                },
                                State {
                                    name: "success"
                                    // Show timeout
                                    PropertyChanges { target: tokenLabel; text: "Connection successful. Remote device listed."; visible: true}
                                    PropertyChanges { target: statusImage; source: "qrc:/images/icons/success_check.svg"; visible: true}

                                    // Hide BusyIndicator
                                    PropertyChanges { target: tokenBusyIndicator; visible: false}

                                    // Show Disconnect
                                    PropertyChanges { target: disconnectButton; visible: true}

                                },
                                State {
                                    name: "error"
                                    // Show error
                                    PropertyChanges { target: tokenLabel; text: "Error with server connection"; visible: true}
                                    PropertyChanges { target: statusImage; source: "qrc:/images/icons/fail_x.svg"; visible: true}

                                    // Hide BusyIndicator
                                    PropertyChanges { target: tokenBusyIndicator; visible: false}

                                    // Show button to try again
                                    PropertyChanges { target: tryAgainButton; visible: true }
                                }
                            ]


                            // Connections for internal event handling
                            Connections{
                                target: submitTokenButton
                                onClicked: {
                                    // Send command to CoreInterface
                                    // Go to connecting
                                    remoteConnectContainer.state = "connecting"
                                }
                            }

                            Connections{
                                target: tokenBusyTimer
                                onTriggered: {
                                    remoteConnectContainer.state = "timeout"
                                }
                            }

                            Connections {
                                target: tryAgainButton
                                onClicked: {
                                    remoteConnectContainer.state = "default"
                                }
                            }

                            Connections {
                                target: disconnectButton
                                onClicked: {
                                    remoteConnectContainer.state = "default"
                                    // sending remote disconnect message to hcs
                                    var remote_disconnect_json = {
                                        "hcs::cmd":"remote_disconnect",
                                    }
                                    coreInterface.sendCommand(JSON.stringify(remote_disconnect_json))
                                    console.log("UI -> HCS ", JSON.stringify(remote_disconnect_json));
                                }
                            }

                            Connections {
                                target: coreInterface
                                onPlatformStateChanged: {
                                    remoteConnectContainer.state = "default"
                                }
                            }

                            Connections {
                                target: coreInterface
                                onRemoteConnectionChanged:{
                                    if ( remoteConnectContainer.state === "connecting") {

                                        // Successful remote connection
                                        if (result === true){
                                            remoteConnectContainer.state = "success"
                                        }
                                        else {
                                            remoteConnectContainer.state = "error"
                                        }
                                    }
                                }
                            }


                            // Timer to timeout busy animation
                            Timer {
                                // 3 second timeout for response
                                id: tokenBusyTimer
                                interval: 3000
                                running: false
                                repeat: false
                                onTriggered: {
                                    // Show failure
                                }
                            }

                            // Show busy
                            Item {
                                id: busyIndicatorContainer
                                width: tokenBusyTimer.running || statusImage.visible ? 75 : 0
                                height: tokenBusyTimer.running || statusImage.visible ? 75 : 0
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    top: parent.top
                                    topMargin: height === 0 ? 0 : 30
                                }

                                BusyIndicator {
                                    id: tokenBusyIndicator
                                    // Bind to Timer
                                    running: tokenBusyTimer.running
                                    anchors.fill: parent
                                }

                                Image{
                                    id: statusImage
                                    width: parent.width
                                    height: parent.height
                                    fillMode: Image.PreserveAspectFit
                                    source: ""
                                    visible: false
                                }
                            }

                            Label {
                                id: tokenLabel
                                height: 30
                                text: "Enter remote token:"
                                font {
                                    family: franklinGothicBold.name
                                }
                                color: "white"
                                anchors {
                                    top: busyIndicatorContainer.bottom
                                    topMargin: busyIndicatorContainer.height === 0 ? 50 : 0
                                    horizontalCenter: remoteConnectContainer.horizontalCenter
                                }
                            }

                            Button {
                                id: tryAgainButton
                                text: "Try Again"
                                anchors {
                                    top: tokenLabel.bottom
                                    horizontalCenter: remoteConnectContainer.horizontalCenter
                                }
                                visible: false
                            }

                            Button {
                                id: disconnectButton
                                text: "Disconnect"
                                anchors {
                                    top: tokenLabel.bottom
                                    horizontalCenter: remoteConnectContainer.horizontalCenter
                                }
                                visible: false
                            }

                            Item {
                                id: tokenInput
                                width: tokenField.width + submitTokenButton.width + submitTokenButton.anchors.leftMargin
                                height: tokenfield.height
                                // Default visibility is false; state changes will make it visible
                                visible: { console.log("created"); return false}
                                anchors {
                                    top: tokenLabel.bottom
                                    horizontalCenter: remoteConnectContainer.horizontalCenter
                                }


                                TextField {
                                    id: tokenField
                                    selectByMouse: true
                                    focus: true
                                    placeholderText: qsTr("Token (ex: DMI2UE1N)")
                                    cursorPosition: 1
                                    Keys.onReturnPressed: {
                                        console.log("TOKEN: ", text);
                                    }


                                }

                                Button{
                                    id: submitTokenButton
                                    text: "Submit"
                                    width: 80
                                    height: tokenfield.height
                                    anchors{
                                        left: tokenField.right
                                        leftMargin: 10
                                    }

                                    onClicked: {
                                        console.log("sending token:", tokenField.text);
                                        var remote_json = {
                                            "hcs::cmd":"get_platforms",
                                            "payload": {
                                                "hcs_token": tokenField.text
                                            }
                                        }
                                        coreInterface.sendCommand(JSON.stringify(remote_json))
                                        console.log("UI -> HCS ", JSON.stringify(remote_json));
                                    }
                                }
                            }






                        }
                    }
                }
            }
        }
    }

    Item {
        id: profileIconContainer
        anchors {
            right: container.right
            rightMargin: 20
            top: container.top
            bottom: container.bottom
        }
        width: height

        Rectangle {
            id: profileIcon
            anchors {
                centerIn: profileIconContainer
            }
            height: profileIconHover.containsMouse ? profileIconContainer.height : profileIconContainer.height - 6
            width: height
            radius: height / 2
            color: "#00b842"

            Text {
                id: profileInitial
                text: getUserName(user_id).charAt(0)
                color: "white"
                anchors {
                    centerIn: profileIcon
                }
                font {
                    family: franklinGothicBold.name
                    pixelSize: profileIconHover.containsMouse ? 24 : 20
                }
            }
        }

        MouseArea {
            id: profileIconHover
            hoverEnabled: true
            anchors {
                fill: profileIconContainer
            }
            onPressed: {
                profileMenu.open()
            }
        }

        Popup {
            id: profileMenu
            x: -width + profileIconContainer.width
            y: profileIconContainer.height
            padding: 0
            topPadding: 10
            width: 100
            background: Canvas {
                width: profileMenu.width
                height: profileMenu.contentItem.height + 10

                onPaint: {
                    var context = getContext("2d");
                    context.reset();
                    context.beginPath();
                    context.moveTo(0, 10);
                    context.lineTo(width - (profileIconContainer.width/2)-10, 10);
                    context.lineTo(width - profileIconContainer.width/2, 0);
                    context.lineTo(width - (profileIconContainer.width/2)+10, 10);
                    context.lineTo(width, 10);
                    context.lineTo(width, height);
                    context.lineTo(0, height);
                    context.closePath();
                    context.fillStyle = "#00b842";
                    context.fill();
                }
            }

            contentItem:
                Column {
                width: profileMenu.width

                SGMenuItem {
                    text: qsTr("My Profile")
                    onClicked: {
                        profileMenu.close()
                        profilePopup.open();
                    }
                    width: profileMenu.width
                }

                SGMenuItem {
                    text: qsTr("Log Out")
                    onClicked: {
                        profileMenu.close()
                        NavigationControl.updateState(NavigationControl.events.LOGOUT_EVENT)
                    }
                    width: profileMenu.width
                }
            }
        }
    }

    Popup {
        id: profilePopup
        width: 500
        height: 500
        modal: true
        focus: true
        x: 200; y: 200
        Rectangle {
            id: popupContainer
            anchors.fill: parent
            width: profilePopup.width;height: profilePopup.height
            color: "lightgray"

            Rectangle {
                id: title
                height: 30
                width: popupContainer.width
                anchors.top: popupContainer.top
                color: "gray"

                Label {
                    id: profileTitle
                    anchors {
                        left: title.left
                        leftMargin: 10
                    }
                    text: "My Profile"
                    font.pointSize: 10
                    font.bold: true
                }
            }

            Image {
                id: profile_image
                anchors { horizontalCenter: popupContainer.horizontalCenter
                    top: popupContainer.top
                    topMargin: 60
                }
                width: 100; height: 100
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/" + getUserImage(user_id)
            }
            Label {
                id:profile_userId
                text: getUserName(user_id)
                anchors {
                    top: profile_image.bottom
                    topMargin: 5
                    horizontalCenter: popupContainer.horizontalCenter

                }
                font.pointSize: 15
                font.bold: true
                color: "black"
            }

            Label {
                id: profile_username
                anchors {
                    top: profile_userId.bottom
                    horizontalCenter: popupContainer.horizontalCenter

                }
                text: getUserName(user_id) + "@onsemi.com"
                anchors.horizontalCenterOffset: 1
                //anchors.topMargin: 18
                font.pointSize: 15
                font.bold: true
                color: "black"
            }

            Label {
                id: email
                text : getJobTitle(user_id)
                anchors.top: profile_username.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter:  popupContainer.horizontalCenter
            }

            Label {
                id: cusomerSupport
                text: "Customer Support: 1800-onsemi-support"
                anchors.top: email.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter:  popupContainer.horizontalCenter
            }

        }
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    }

    FontLoader {
        id: franklinGothicBook
        source: "qrc:/fonts/FranklinGothicBook.otf"
    }

    FontLoader {
        id: franklinGothicBold
        source: "qrc:/fonts/FranklinGothicBold.ttf"
    }

    FontLoader {
        id: sgicons
        source: "qrc:/fonts/sgicons.ttf"
    }

    Window {
        id: debugWindow
        visible:true
        height: 400
        width: 400
        x:1520
        y:500

        Button {
            id: whatever
            text: "add user to model"
            onClicked: {
                remoteUserModel.append({"name":"David Faller" })
                remote_activity_label.visible = true;
                remote_activity_label.text= "Controlled by David Faller";
                activityMonitorTimer.start();
            }
        }
        Button {
            id: whatever2
            text: "clear model"
            anchors {
                top: whatever.bottom
            }
            onClicked: {
                remoteUserModel.clear()
            }
        }
    }
}
