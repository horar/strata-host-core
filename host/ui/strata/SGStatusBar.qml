import QtQuick 2.10 // to support scale animator
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "js/navigation_control.js" as NavigationControl


Rectangle {
    id: container
    anchors.fill: parent

    // Context properties that get passed when created dynamically
    property string user_id: ""
    property bool is_logged_in: false
    property bool is_remote_connected: false
    property string generalTitle: "Guest"
    property color backgroundColor: "#C0C0C0"

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

    Popup {
        id: remoteSupportConnect
        x: 400; y: 200
        width: 400; height: 200
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        onOpened: {
            console.log("opened!")
        }

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
                        is_remote_connected = true
                    }
                    else {
                        remoteConnectContainer.state = "error"
                    }
                }
            }
       }

        Rectangle {
            id: remoteConnectContainer
            anchors.fill: parent
            state: "default"
            states: [
                State {
                    name: "default"
                    // Show button and textfield
                    PropertyChanges { target: tokenLabel; text: "Enter remote token"; visible: true}
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

            ColumnLayout{
                id: remoteColumn
                anchors.fill: parent

                spacing: 2
                // Show busy
                Rectangle {
                    Layout.alignment: Qt.AlignTop
                    width: tokenBusyIndicator.width
                    height: tokenBusyIndicator.height
                    anchors.horizontalCenter: remoteColumn.horizontalCenter

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
                    }
                }

                Label {
                    id: tokenLabel
                    height: 30
                    text: "Enter remote token"
                    font.pointSize: 15
                    font.bold: true
                    color: "dark blue"
                    Layout.alignment: Qt.AlignCenter
                }
                Button {
                    id: tryAgainButton
                    text: "Try Again"
                    Layout.alignment: Qt.AlignCenter
                    anchors.horizontalCenter: remoteColumn.horizontalCenter
                    visible: false
                }
                Button {
                    id: disconnectButton
                    text: "Disconnect"
                    Layout.alignment: Qt.AlignCenter
                    anchors.horizontalCenter: remoteColumn.horizontalCenter
                    visible: false
                }

                Rectangle{
                    id: tokenInput
                    width: 300
                    height: 50
                    // Default visibility is false; state changes will make it visible
                    visible: { console.log("created"); return false}

                    Layout.alignment: Qt.AlignBottom
                    anchors.horizontalCenter: remoteColumn.horizontalCenter
                    TextField {
                        id: tokenField
                        width: 184; height: 38
                        selectByMouse: true
                        focus: true
                        placeholderText: qsTr("TOKEN")
                        cursorPosition: 1
                        font.pointSize: Qt.platform.os == "osx"? 13 :8
                        Keys.onReturnPressed:{
                            console.log("TOKEN: ", text);
                        }
                    }
                    Button{
                        id: submitTokenButton
                        text: "Submit"
                        width: 80; height: 38
                        anchors{
                            left:tokenField.right
                        }
                        onClicked: {
                            console.log("sending token:", tokenField.text);
                            var remote_json = {
                                "hcs::cmd":"get_platforms",
                                "payload": {
                                    "hcs_token":tokenField.text
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

    Popup {
        id: remoteSupportRequest
        x: 400; y: 200
        width: 400; height: 400
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Rectangle{
            id:advertiseButton;
            width: 100;
            height: 100;
            anchors {
                horizontalCenter: remoteSupportRequest.horizontalCenter
                margins: 30
            }
            property bool checked: false
            border.color: "black";
            border.width: 2;
            color: advertiseButton.checked ? "lightgreen":"lightgrey"
            Image{
                id:remoteButtonImage
                source: "qrc:/images/icons/remotecommunication.svg"
                height: advertiseButton.height
                width: advertiseButton.width
            }
            ScaleAnimator {
                id: increaseOnMouseEnter
                target: advertiseButton;
                from: 1;
                to: 1.2;
                duration: 200
                running: false
            }
            ScaleAnimator {
                id: decreaseOnMouseExit
                target: advertiseButton;
                from: 1.2;
                to: 1;
                duration: 200
                running: false
            }
            MouseArea {
                id: imageMouse
                anchors.fill: advertiseButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered:{
                    increaseOnMouseEnter.start()
                }
                onExited:{
                    decreaseOnMouseExit.start()
                }
                onClicked: {
                    advertiseButton.checked = !advertiseButton.checked
                    var advertise;

                    if(advertiseButton.checked) {
                        advertise = true
                    }
                    else {
                        advertise = false
                        remote_activity_label.visible = false
                        remote_user_container.visible = false
                        remote_user_label.visible = false
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
        }

        Label {
            id:supportPhoneNumber
            anchors {
                top:advertiseButton.bottom
                horizontalCenter: remoteSupportRequest.horizontalCenter
                margins: 30
            }
            text: advertiseButton.checked ? "click the button to turn off remote control":"click the button to turn on remote control"
            font.pointSize: Qt.platform.os == "osx"? 13 :8
            font.bold: true
            color: "black"
        }

        Label {
            id:hcs_token
            anchors {
                top:supportPhoneNumber.bottom
                horizontalCenter: remoteSupportRequest.horizontalCenter
                margins: 30
            }
            text: advertiseButton.checked ? coreInterface.hcs_token_:""
            font.pointSize: Qt.platform.os == "osx"? 13 :8
            font.bold: true
            color: "black"
        }
        Connections {
            target: coreInterface
            onPlatformStateChanged: {
                remoteButton.checked = false
            }
        }
    }

    Image {
        id: user_img
        anchors { left: container.left }
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
        sourceSize.width: 1024; sourceSize.height: 1024

        height: parent.height
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/" + getUserImage(user_id)
    }

    Label {
        id: userNameLabel

        anchors {
            left: user_img.right;
            leftMargin: 10;
            verticalCenter: container.verticalCenter;
            verticalCenterOffset: 10
        }

        height: parent.height
        text:  getUserName(user_id)
        font.pointSize: Qt.platform.os == "osx"? 13 :8
        font.bold: true
        color: "white"
    }

    Label {
        id:remote_user_label
        anchors {
            left: settingsToolButton.right;
            verticalCenter: container.verticalCenter;
            verticalCenterOffset: 10
        }

        height: parent.height
        text:  "Remote User/s:"
        font.pointSize: Qt.platform.os == "osx"? 13 :8
        font.bold: true
        color: "white"
        visible:false
    }

    ListModel {
        id: remoteUserModel
    }

    Rectangle {
        id: remote_user_container
        anchors {
            left: remote_user_label.right
            leftMargin: 10
        }
        height: parent.height
        width: parent.width*0.6
        visible:false
        color: container.backgroundColor
        Component {
            id: remoteUserDelegate
            Item {
                width: remote_user_container.width*0.1
                height: remote_user_container.height
                Rectangle{
                    Image {
                        id: remote_user_img
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                        }

                        sourceSize.width: 1024;
                        height: remote_user_container.height*.7
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/images/blank_avatar.png"
                        Image {
                            id: close_icon
                            anchors {
                                top: parent.top
                                left: parent.left
                            }
                            height: parent.height*0.5
                            width:parent.width*0.5
                            fillMode: Image.PreserveAspectFit
                            source: "qrc:/images/closeIcon.svg"
                            visible: false
                        }
                        MouseArea {
                                anchors.fill: remote_user_img
                                hoverEnabled: true
                                onEntered: { close_icon.visible = true }
                                onExited: { close_icon.visible = false }
                                onClicked: {
                                    var remote_json = {
                                        "hcs::cmd":"disconnect_remote_user",
                                        "payload": {
                                            "user_name":name
                                        }
                                    }
                                    console.log("disconnecting user",JSON.stringify(remote_json))
                                    coreInterface.sendCommand(JSON.stringify(remote_json))
//                                    remoteUserModel.remove(remote_user_list_view.currentIndex,1)

                                }
                            }
                    }
                    Label {
                        id:remote_user_name
                        anchors {
                            top: remote_user_img.bottom
                            horizontalCenter: parent.horizontalCenter;
                        }
                        text:  name
                        font.pointSize: Qt.platform.os == "osx"? 13 :8
                        font.bold: true
                        color: "white"
                    }

                }
            }

        }
        ListView {
            id: remote_user_list_view
            anchors.fill: remote_user_container
            model: remoteUserModel
            delegate: remoteUserDelegate
            orientation: ListView.Horizontal
            focus: true
        }
    }

    Connections {
        target: coreInterface
        onRemoteUserAdded: {
            remote_user_container.visible = true;
            remoteUserModel.append({"name":user_name, "active":false})
            remote_user_label.visible = true;
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
             remote_user_container.visible = false;
             remote_user_label.visible = false;
             tokenField.text = "";
 // send "close remote advertise to hcs to close the remote socket"
             if(advertiseButton.checked) {
                remoteUserModel.clear()
                advertiseButton.checked = false;
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

    Label {
        id:remote_activity_label
        anchors { left: remote_user_container.right;  leftMargin: 15 ;
            verticalCenter: container.verticalCenter;
            verticalCenterOffset: 10
        }
        height: parent.height
        text: ""
        font.pointSize: Qt.platform.os == "osx"? 13 :8
        font.bold: true
        color: "white"
    }

    Connections {
        target: coreInterface
        onRemoteActivityChanged: {
            remote_activity_label.visible = true;
            remote_activity_label.text= "controlled by "+ coreInterface.remote_user_activity_;
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
            remote_activity_label.text="";
        }
    }

    Image {
        height: container.height
        anchors { right: container.right }
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/icons/onLogoGrey.svg"
    }

    ToolButton {
        id: settingsToolButton

        anchors { left: userNameLabel.right;  leftMargin: 10 }
        width: 30; height: parent.height
        onClicked: settingsMenu.open()
        opacity: 1

        Label {
            anchors { fill: parent }

            text: qsTr("\u22EE")
            elide: Label.ElideRight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            Layout.fillWidth: true
            font.pixelSize: 20
            font.bold: true
            color: "black"

            background: Rectangle {
                anchors { fill: parent }
                color: backgroundColor
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

            Menu {
                id: settingsMenu
                title: "setting"
                y: settingsToolButton.y + settingsToolButton.height //To move the drop down menu below the setting icon

                MenuItem {
                    text: qsTr("Log out")
                    onClicked: {
                        NavigationControl.updateState(NavigationControl.events.LOGOUT_EVENT)
                        remoteConnectContainer.state = "default"
                        if(is_remote_connected) {
                            // sending remote disconnect message to hcs
                            var remote_disconnect_json = {
                                "hcs::cmd":"remote_disconnect",
                            }
                            coreInterface.sendCommand(JSON.stringify(remote_disconnect_json))

                            console.log("UI -> HCS ", JSON.stringify(remote_disconnect_json))
                        }
                    }
                }

                MenuItem {
                    text: qsTr("Remote Support FAE")

                    onClicked: {
                        remoteSupportConnect.open()

                    }
                }

                MenuItem {
                    text: qsTr("Remote Support CUSTOMER")

                    onClicked: {
                        remoteSupportRequest.open()
                    }
                }

                MenuItem {
                    text: qsTr("My Profile")
                    onClicked: profilePopup.open();
                }

            }

    }
}
