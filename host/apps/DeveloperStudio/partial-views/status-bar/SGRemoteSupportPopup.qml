import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/partial-views/status-bar"
import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0
import tech.strata.logger 1.0

Popup {
    id: remoteSupportMenu
    padding: 0
    width: 500
    height: 250

    property alias remoteUserModel: remoteUserModel

    DropShadow {
        width: remoteSupportMenu.width
        height: remoteSupportMenu.height
        horizontalOffset: 1
        verticalOffset: 1
        radius: 8.0
        samples: 15
        color: "#88000000"
        source: remoteSupportMenu.background
        z: -1
        cached: true
    }

    background: Rectangle {
        color: alternateColor1
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
                buttonColor: checked ? alternateColor1 : backgroundColor
                enabled : !is_remote_connected
            }

            SGTabButton {
                text: qsTr("Connect to Remote")
                onClicked: {
                    remoteInviteContainer.visible = false
                    remoteConnectContainer.visible = true
                    tokenField.forceActiveFocus();
                }
                buttonColor: checked ? alternateColor1 : backgroundColor
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
                id: noConnectedPlatContainer
                anchors {
                    fill: remoteInviteContainer
                }
                z:10
                visible: PlatformSelection.platformListModel.selectedConnection !== "connected"

                onVisibleChanged: {
                    if (visible) {
                        remoteToggle.checked = false
                    }
                }

                Rectangle {
                    id: noConnectedPlatWarning
                    color: backgroundColor
                    anchors {
                        centerIn: noConnectedPlatContainer
                    }
                    z:12
                    width: noConnectedPlatText.width + 20
                    height: noConnectedPlatText.height + 20

                    TextEdit {
                        id: noConnectedPlatText
                        anchors {
                            centerIn: noConnectedPlatWarning
                        }
                        text: "Select a Connected Platform to\n Enable Incoming Remote Connections"
                        color: "white"
                        readOnly: true
                        horizontalAlignment: TextEdit.AlignHCenter
                    }
                }

                Rectangle {
                    id: noConnectedPlatOverlay
                    color: alternateColor1
                    opacity: .8
                    anchors {
                        fill: noConnectedPlatContainer
                    }
                    z:11

                    MouseArea {
                        anchors {
                            fill: noConnectedPlatOverlay
                        }
                    }
                }
            }

            Item {
                id: remoteInviteLeft
                width: 270
                anchors {
                    margins: 15
                    top: remoteInviteContainer.top
                    bottom: remoteInviteContainer.bottom
                    left: remoteInviteContainer.left
                }

                Image {
                    id: remoteImage
                    source: remoteToggle.checked ? "qrc:/images/icons/remote-unlocked.png" : "qrc:/images/icons/remote-locked.png"
                    anchors {
                        horizontalCenter: remoteInviteLeft.horizontalCenter
                        top: remoteInviteLeft.top
                    }
                }

                SGSwitch {
                    id: remoteToggle
                    anchors {
                        top: remoteImage.bottom
                        topMargin: 15
                        horizontalCenter: remoteInviteLeft.horizontalCenter
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
                        var advertise;
                        if (remoteToggle.checked) {
                            advertise = true
                            is_remote_advertised = true
                            tokenTimer.start()
                        } else {
                            hcs_token_status.text= qsTr("Enable to generate remote token")
                            advertise = false
                            hcs_token.text = ""
                            tokenTimer.running = false
                            remoteUserModel.clear()
                        }
                        var remote_json = {
                            "hcs::cmd":"advertise",
                            "payload": {
                                "advertise_platforms":advertise
                            }
                        }
                        console.log(Logger.devStudioCategory, "asking hcs to advertise the platforms",JSON.stringify(remote_json))
                        coreInterface.sendCommand(JSON.stringify(remote_json))
                    }
                }

                Row {
                    id: tokenRow
                    anchors {
                        top: remoteToggle.bottom
                        horizontalCenter: remoteInviteLeft.horizontalCenter
                        topMargin: 20
                    }


                    Item {
                        id: tokenStatusContainer
                        height: 25
                        width: hcs_token_status.width

                        Text {
                            id: hcs_token_status
                            text : qsTr("Enable to generate remote token")
                            font {
                                family: Fonts.franklinGothicBook
                            }
                            color: "white"
                            //readOnly: true
                            anchors {
                                topMargin: 7
                                top: tokenStatusContainer.top
                            }
                        }

                    }

                    Rectangle {
                        id: tokenContainer
                        visible: hcs_token.text !== ""
                        height: 25
                        color: "#ddd"
                        width: 100

                        TextEdit {
                            id: hcs_token
                            visible: text !== ""
                            text: ""
                            readOnly: true
                            font {
                                family: Fonts.inconsolata
                                pixelSize: 20
                            }
                            selectByMouse: true

                            anchors {
                                centerIn: tokenContainer
                            }
                        }
                    }


                }

                Connections {
                    target: coreInterface
                    onPlatformStateChanged: {
                        remoteToggle.checked = false
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

                Timer {
                    // 3 second timeout for response
                    id: tokenTimer
                    interval: 3000
                    running: false
                    repeat: false
                    onRunningChanged: {
                        if (running) {
                            hcs_token_status.text = qsTr("Generating token...")
                        }
                    }
                    onTriggered: {
                        remoteToggle.checked = false
                        hcs_token_status.text = qsTr("ERROR: Generation failed, enable to retry")
                    }
                }

                Connections {
                    target: coreInterface
                    onHcsTokenChanged: {

                        hcs_token.text =  coreInterface.hcs_token_
                        if(hcs_token.text === "") {
                            return;
                        }
                        else {
                            hcs_token_status.text = qsTr("Your remote token is: ")
                            tokenTimer.stop()
                        }
                    }
                }
            }

            Item {
                id: remoteInviteRight
                anchors {
                    left: remoteInviteLeft.right
                    top: remoteInviteContainer.top
                    bottom: remoteInviteContainer.bottom
                    right: remoteInviteContainer.right
                    leftMargin: 15
                    topMargin: 10
                    rightMargin: 5
                }

                Rectangle {
                    id: connectedUsersTitle
                    anchors {
                        left: remoteInviteRight.left
                        right: remoteInviteRight.right
                        top: remoteInviteRight.top
                    }
                    height: 30
                    color: remoteToggle.checked ? Qt.darker(backgroundColor, 1.25) : backgroundColor

                    Text {
                        id: connectedUsersTitleText
                        text: remoteUserModel.count === 0 ? qsTr("No Connected Users") : qsTr("Connected Users")
                        anchors {
                            verticalCenter: connectedUsersTitle.verticalCenter
                            left: connectedUsersTitle.left
                            leftMargin: 10
                            verticalCenterOffset: 2
                        }
                        color: remoteToggle.checked ? "white" : "grey"
                        font {
                            family: Fonts.franklinGothicBook
                        }
                    }
                }

                Rectangle {
                    id: connectedUsersContainer
                    color: remoteToggle.checked ? backgroundColor : "#484848"
                    anchors {
                        left: remoteInviteRight.left
                        right: remoteInviteRight.right
                        top: connectedUsersTitle.bottom
                        topMargin: 2
                        bottom: remoteInviteRight.bottom
                        bottomMargin: 10
                    }

                    ListModel {
                        id: remoteUserModel
                    }

                    Component {
                        id: remoteUserDelegate

                        Item {
                            id: remoteUserDelegateContainer
                            width: connectedUsersContainer.width
                            height: 50

                            Image {
                                id: remote_user_img
                                anchors {
                                    left: remoteUserDelegateContainer.left
                                    top: remoteUserDelegateContainer.top
                                    leftMargin: 4
                                    topMargin: 4
                                }
                                sourceSize.height: 46
                                fillMode: Image.PreserveAspectFit
                                source: "qrc:/images/blank_avatar.png"
                            }

                            Label {
                                id:remote_user_name
                                anchors {
                                    left: remote_user_img.right
                                    verticalCenter: remoteUserDelegateContainer.verticalCenter
                                    leftMargin: 10
                                    right: close_icon.left
                                }
                                text: name
                                font {
                                    family: Fonts.franklinGothicBold
                                }
                                color: "white"
                                elide: Text.ElideRight
                            }

                            SGIcon {
                                id: close_icon
                                anchors {
                                    verticalCenter: remoteUserDelegateContainer.verticalCenter
                                    right: remoteUserDelegateContainer.right
                                    rightMargin: 5
                                }
                                height: remoteUserDelegateContainer.height - 30
                                width: height
                                source: "qrc:/images/icons/times.svg"
                                iconColor: "red"
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
                                    console.log(Logger.devStudioCategory, "disconnecting user",JSON.stringify(remote_json))
                                    coreInterface.sendCommand(JSON.stringify(remote_json))

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
                    PropertyChanges { target: statusImage; source: "qrc:/images/icons/times-circle-solid.svg"; iconColor: "red"; visible: true}

                    // Hide BusyIndicator
                    PropertyChanges { target: tokenBusyIndicator; visible: false}

                    // Show button to try again
                    PropertyChanges { target: tryAgainButton; visible: true }
                },
                State {
                    name: "success"
                    // Show timeout
                    PropertyChanges { target: tokenLabel; text: "Connection successful. Remote device listed."; visible: true}
                    PropertyChanges { target: statusImage; source: "qrc:/images/icons/check-circle-solid.svg"; iconColor: "#30c235"; visible: true}

                    // Hide BusyIndicator
                    PropertyChanges { target: tokenBusyIndicator; visible: false}

                    // Show Disconnect
                    PropertyChanges { target: disconnectButton; visible: true}

                },
                State {
                    name: "error"
                    // Show error
                    PropertyChanges { target: tokenLabel; text: "Error with server connection"; visible: true}
                    PropertyChanges { target: statusImage; source: "qrc:/images/icons/times-circle-solid.svg"; iconColor: "red"; visible: true}

                    // Hide BusyIndicator
                    PropertyChanges { target: tokenBusyIndicator; visible: false}

                    // Show button to try again
                    PropertyChanges { target: tryAgainButton; visible: true }
                }
            ]


            // Connections for internal event handling
            Connections{
                target: tokenField
                onAccepted: {
                    remoteConnectContainer.state = "connecting"
                }
            }

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
                    console.log(Logger.devStudioCategory, "try again")
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
                        "payload":{}
                    }
                    coreInterface.sendCommand(JSON.stringify(remote_disconnect_json))
                    console.log(Logger.devStudioCategory, "UI -> HCS ", JSON.stringify(remote_disconnect_json));
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
                    horizontalCenter: remoteConnectContainer.horizontalCenter
                    top: remoteConnectContainer.top
                    topMargin: height === 0 ? 0 : 30
                }

                BusyIndicator {
                    id: tokenBusyIndicator
                    // Bind to Timer
                    running: tokenBusyTimer.running
                    anchors { fill: busyIndicatorContainer }
                }

                SGIcon {
                    id: statusImage
                    width: busyIndicatorContainer.width
                    height: busyIndicatorContainer.height
                    source: ""
                    visible: false
                }
            }

            Label {
                id: tokenLabel
                height: 30
                text: "Enter remote token:"
                font {
                    family: Fonts.franklinGothicBold
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
                focus: true
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
                onClicked: {
                    is_remote_connected = false
                }
            }

            Item {
                id: tokenInput
                width: tokenField.width + submitTokenButton.width + submitTokenButton.anchors.leftMargin
                height: tokenField.height
                // Default visibility is false; state changes will make it visible
                visible: { console.log(Logger.devStudioCategory, "created"); return false}
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
                    font.capitalization: Font.AllUppercase

                    onAccepted: {
                        focus = false
                        console.log(Logger.devStudioCategory, "TOKEN: ", text);
                        console.log(Logger.devStudioCategory, "sending token:", tokenField.text);
                        var remote_json = {
                            "hcs::cmd":"get_platforms",
                            "payload": {
                                "hcs_token": tokenField.text.toUpperCase()
                            }
                        }
                        coreInterface.sendCommand(JSON.stringify(remote_json))
                        console.log(Logger.devStudioCategory, "UI -> HCS ", JSON.stringify(remote_json));
                    }

                }

                Button{
                    id: submitTokenButton
                    text: "Submit"
                    width: 80
                    height: tokenField.height
                    anchors{
                        left: tokenField.right
                        leftMargin: 10
                    }
                    font.capitalization: Font.AllUppercase

                    onClicked: {
                        console.log(Logger.devStudioCategory, "sending token:", tokenField.text);
                        var remote_json = {
                            "hcs::cmd":"get_platforms",
                            "payload": {
                                "hcs_token": tokenField.text.toUpperCase()
                            }
                        }
                        coreInterface.sendCommand(JSON.stringify(remote_json))
                        console.log(Logger.devStudioCategory, "UI -> HCS ", JSON.stringify(remote_json));
                    }
                }
            }
        }
    }
}

