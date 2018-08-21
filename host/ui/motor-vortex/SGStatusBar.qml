import QtQuick 2.10 // to support scale animator
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Window 2.3 // for debug window, can be cut out for release
import QtGraphicalEffects 1.0
import "js/navigation_control.js" as NavigationControl
import "qrc:/statusbar-partial-views"


Rectangle {
    id: container
    anchors { fill: parent }

    // Context properties that get passed when created dynamically
    property string user_id: ""
    property bool is_logged_in: false
    property bool is_remote_connected: false
    property bool is_remote_advertised: false
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
            //resetting the remote connection state
            is_remote_connected = false;
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
            left: remote_user_icons.right
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
            leftMargin: 5
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

    SGComboBox {
        id: cbSelector
        anchors {
            verticalCenter: container.verticalCenter
            left: container.left
            leftMargin: 3
        }

        comboBoxWidth: 250
        textRole: "text"
        TextMetrics { id: textMetrics }
        model: platformListModel


        onActivated: {
            /*
           Determine action depending on what type of 'connection' is used
        */
            NavigationControl.updateState(NavigationControl.events.PLATFORM_DISCONNECTED_EVENT, null)
            var disconnect_json = {"hcs::cmd":"disconnect_platform"}
            console.log("disonnecting the platform")
            coreInterface.sendCommand(JSON.stringify(disconnect_json))

            var connection = platformListModel.get(cbSelector.currentIndex).connection
            var data = { platform_name: platformListModel.get(cbSelector.currentIndex).name}

            // Clear all documents for contents
            documentManager.clearDocumentSets();

            if (connection === "view") {
                // Go offline-mode
                NavigationControl.updateState(NavigationControl.events.OFFLINE_MODE_EVENT, data)
                NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
                coreInterface.sendSelectedPlatform(platformListModel.get(cbSelector.currentIndex).uuid,platformListModel.get(cbSelector.currentIndex).connection)

            }
            else if(connection === "connected"){
                NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT,data)
                coreInterface.sendSelectedPlatform(platformListModel.get(cbSelector.currentIndex).uuid,platformListModel.get(cbSelector.currentIndex).connection)
            }
            else if( connection === "remote"){
                NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT,data)
                // Call coreinterface connect()
                console.log("calling the send");
                coreInterface.sendSelectedPlatform(platformListModel.get(cbSelector.currentIndex).uuid,platformListModel.get(cbSelector.currentIndex).connection)
            }
        }
    }

    Connections {
        target: coreInterface
        onPlatformListChanged: {
            console.log("platform list updated: ", list)
            container.populatePlatforms(list)
        }
    }

    ListModel {
        id: platformListModel


        Component.onCompleted: {
            console.log("platformListModel:Component.onCompleted:");
            container.populatePlatforms(coreInterface.platform_list_)
        }

        // DEBUG hard code model data for testing
        //            ListElement {
        //                text: "Motor Vortex"
        //                name: "motor-vortex" // folder name of qml
        //                verbose: "motor-vortex"
        //                connection: "local"
        //            }

        //            ListElement {
        //                text: "USB PD"
        //                name: "bubu"
        //                verbose: "usb-pd"
        //                connection: "local"
        //            }
    }

    function updateComboWidth(newModel) {
        // Update our width depending on the children text size
        var maxWidth = 0
        textMetrics.font = cbSelector.font
        for(var i = 0; i < newModel.count; i++){
            textMetrics.text = newModel.get(i).text
            maxWidth = Math.max(textMetrics.width, maxWidth)
        }
        // Add some padding for the selector arrows
        cbSelector.width = maxWidth + 60
    }

    function populatePlatforms(platform_list_json) {
        var autoSelectEnabled = true
        var autoSelectedPlatform = null

        // Map out UUID->platform name
        // Lookup table
        //  platform_id -> local qml directory holding interface
        var uuid_map = {
            "P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af" : "usb-pd",
            //"P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af" : "motor-vortex",
            "P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671" : "bubu",
            "SEC.2018.004.1.1.0.2.20180710161919.1bfacee3-fb60-471d-98f8-fe597bb222cd" : "usb-pd-multiport",
            "motorvortex1" : "motor-vortex"
        }

        platformListModel.clear()

        // Parse JSON
        try {
            console.log("populatePlaforms: ", platform_list_json)
            var platform_list = JSON.parse(platform_list_json)

            for (var i = 0; i < platform_list.list.length; i ++){
                // Extract platform verbose name and UUID
                var platform_info = {
                    "text" : platform_list.list[i].verbose,
                    "verbose" : platform_list.list[i].verbose,
                    "name" : uuid_map[platform_list.list[i].uuid],
                    "connection" : platform_list.list[i].connection,
                    "uuid"  :   platform_list.list[i].uuid
                }

                // Append text to state the type of Connection
                if(platform_list.list[i].connection === "remote"){
                    platform_info.text += " (Remote)"
                }
                else if (platform_list.list[i].connection === "view"){
                    platform_info.text += " (View-only)"
                }
                else {
                    platform_info.text += " (Connected)"
                    // copy "connected" platform; Note: this will auto select the last listed "connected" platform
                    autoSelectedPlatform = platform_info
                }

                // Add to the model
                // TODO update width of text here instead of adding to model and then re-reading model and updating
                platformListModel.append(platform_info)
            }

        }
        catch(err) {
            console.log("CoreInterface error: ", err.toString())
            platformListModel.clear()
            platformListModel.append({ text: "No Platforms Available" } )
        }

        // Auto Select "connected" platform
        if ( autoSelectEnabled && autoSelectedPlatform) {
            console.log("Auto selecting connected platform: ", autoSelectedPlatform.name)

            // For Demo purposes only; Immediately go to control
            var data = { platform_name: autoSelectedPlatform.name}
            coreInterface.sendSelectedPlatform(autoSelectedPlatform.uuid, autoSelectedPlatform.connection)
            NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT,data)
        }
        else if ( autoSelectEnabled == false){
            console.log("Auto selecting disabled.")
        }
    }

    ToolBar {
        id: toolBar
        anchors {
            left: cbSelector.right
            leftMargin: 10
        }
        background: Rectangle {
            color: container.color
            height: container.height
        }

        Row {
            SGToolButton {
                id: platformControlsButton
                text: qsTr("Platform Controls")
                width: 150
                buttonColor: hovered || !NavigationControl.flipable_parent_.flipped ? Qt.lighter(container.color) : container.color
                onClicked: {
                    if (NavigationControl.flipable_parent_.flipped) {
                        NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
                    }
                }
            }

            SGToolButton {
                id: platformContentButton
                text: qsTr("Platform Content")
                width: 150
                buttonColor: hovered || NavigationControl.flipable_parent_.flipped ? Qt.lighter(container.color) : container.color
                onClicked: {
                    if (!NavigationControl.flipable_parent_.flipped) {
                        NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
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
                                enabled : !is_remote_connected

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
                                        if(remoteToggle.checked) {

                                            advertise = true
                                            is_remote_advertised = true
                                            tokenTimer.start()
                                        }
                                        else {
                                            hcs_token_status.text= qsTr("Enable to generate remote token")
                                            advertise = false
                                            hcs_token.text = ""
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
                                                family: franklinGothicBook.name
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
                                                family: inconsolata.name
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
                                        hcs_token_status.text = qsTr("Error: Cannot generate token")
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
                                    color: remoteToggle.checked ? Qt.darker(container.color, 1.25) : container.color

                                    Text {
                                        id: name
                                        text: remoteUserModel.count === 0 ? qsTr("No Connected Users") : qsTr("Connected Users")
                                        anchors {
                                            verticalCenter: connectedUsersTitle.verticalCenter
                                            left: connectedUsersTitle.left
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
                                    console.log("try again")
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
                                onClicked: {
                                    is_remote_connected = false
                                }
                            }

                            Item {
                                id: tokenInput
                                width: tokenField.width + submitTokenButton.width + submitTokenButton.anchors.leftMargin
                                height: tokenField.height
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

                                    onAccepted: {
                                        console.log("TOKEN: ", text);
                                        console.log("sending token:", tokenField.text);
                                        var remote_json = {
                                            "hcs::cmd":"get_platforms",
                                            "payload": {
                                                "hcs_token": tokenField.text.toUpperCase()
                                            }
                                        }
                                        coreInterface.sendCommand(JSON.stringify(remote_json))
                                        console.log("UI -> HCS ", JSON.stringify(remote_json));
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

                                    onClicked: {
                                        console.log("sending token:", tokenField.text);
                                        var remote_json = {
                                            "hcs::cmd":"get_platforms",
                                            "payload": {
                                                "hcs_token": tokenField.text.toUpperCase()
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


    Component {
        id: remoteUserIconDelegate

        Item {
            id: remote_icon_container
            width: remote_user_hover.containsMouse ? remote_user_img.width + 18 : remote_user_img.width
            height: 40
            clip: false

            Behavior on width { NumberAnimation {
                    duration: 50
                }
            }

            Image {
                id: remote_user_img
                sourceSize.height: 40
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/blank_avatar.png"
                visible: false
                anchors {
                    right: remote_icon_container.right
                }
            }

            Rectangle {
                id: mask
                width: remote_user_img.width
                height: width
                radius: width/2
                visible: false
                anchors {
                    right: remote_icon_container.right
                }
            }

            OpacityMask {
                height: mask.width
                width: mask.height
                source: remote_user_img
                maskSource: mask
                anchors {
                    right: remote_icon_container.right
                }

                ToolTip {
                    text: model.name
                    visible: remote_user_hover.containsMouse
                }
            }

            MouseArea {
                id: remote_user_hover
                anchors {
                    fill: parent
                }
                hoverEnabled: true
            }
        }
    }

    Row {
        id: remote_user_icons
        anchors {
            left: toolBar.right
            leftMargin: 18
        }
        width: icon_repeater.count * 19 + 16
        height: 40
        y: 2
        spacing: -16
        layoutDirection: Qt.RightToLeft
        clip: false

        Repeater {
            id: icon_repeater
            model: remoteUserModel
            delegate: remoteUserIconDelegate
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
                        remoteConnectContainer.state = "default"


                        if(is_remote_connected) {
                            is_remote_connected = false //resetting the remote connection state
                            // sending remote disconnect message to hcs
                            var remote_disconnect_json = {
                                "hcs::cmd":"remote_disconnect",
                            }
                            coreInterface.sendCommand(JSON.stringify(remote_disconnect_json))

                            console.log("UI -> HCS ", JSON.stringify(remote_disconnect_json))
                        }

                        if(is_remote_advertised){
                            is_remote_advertised = false
                            var remote_json = {
                                "hcs::cmd":"advertise",
                                "payload": {
                                    "advertise_platforms":is_remote_advertised
                                }
                            }
                            console.log("asking hcs to advertise the platforms",JSON.stringify(remote_json))
                            coreInterface.sendCommand(JSON.stringify(remote_json))
                        }



                    }
                    width: profileMenu.width
                }
            }
        }
    }

    Popup {
        id: profilePopup
        width: 500
        height: 175 + profile_image.height
        modal: true
        focus: true
        x: container.width/2 - profilePopup.width/2
        y: container.parent.windowHeight/2 - profilePopup.height/2
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Rectangle {
            id: popupContainer
            anchors.fill: parent
            width: profilePopup.width
            height: profilePopup.height
            color: Qt.lighter("#3a3a3a")

            Rectangle {
                id: title
                height: 30
                width: popupContainer.width
                anchors.top: popupContainer.top
                color: "#3a3a3a"

                Label {
                    id: profileTitle
                    anchors {
                        left: title.left
                        leftMargin: 10
                        verticalCenter: title.verticalCenter
                    }
                    text: "My Profile"
                    font {
                        family: franklinGothicBold.name
                    }
                    color: "white"
                }

                Text {
                    id: close_profile
                    text: "\ue805"
                    color: "white"
                    font {
                        family: sgicons.name
                        pixelSize: 20
                    }
                    anchors {
                        right: title.right
                        verticalCenter: title.verticalCenter
                        rightMargin: 10
                    }

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        onClicked: profilePopup.close()
                    }
                }
            }

            Image {
                id: profile_image
                anchors { horizontalCenter: popupContainer.horizontalCenter
                    top: popupContainer.top
                    topMargin: 50
                }
                sourceSize.width: 200
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
                font {
                    pixelSize: 25
                    family: franklinGothicBold.name
                }
                color: "white"
            }

            Label {
                id: profile_email
                anchors {
                    top: profile_userId.bottom
                    horizontalCenter: popupContainer.horizontalCenter
                    horizontalCenterOffset: 1
                    topMargin: 5
                }
                text: getUserName(user_id) + "@onsemi.com"
                font {
                    pixelSize: 15
                    family: franklinGothicBook.name
                }
                color: "white"
            }

            Label {
                id: jobTitle
                text : getJobTitle(user_id)
                anchors {
                    top: profile_email.bottom
                    topMargin: 5
                    horizontalCenter:  popupContainer.horizontalCenter
                }
                color: "white"
                font {
                    pixelSize: 15
                    family: franklinGothicBook.name
                }
            }

            Label {
                id: cusomerSupport
                text: "Customer Support: 1800-onsemi-support"
                anchors{
                    top: jobTitle.bottom
                    topMargin: 10
                    horizontalCenter:  popupContainer.horizontalCenter
                }
                color: "white"
                font {
                    pixelSize: 15
                    family: franklinGothicBook.name
                }
            }
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

    FontLoader {
        id: sgicons
        source: "qrc:/fonts/sgicons.ttf"
    }

    FontLoader {
        id: inconsolata
        source: "qrc:/fonts/Inconsolata.otf"
    }

    Window {
        id: debugWindow
        visible: container.parent.showDebug
        height: 200
        width: 300
        x: 1620
        y: 500
        title: "SGStatusBar.qml Debug Controls"

        Column {
            id: debug1
            Button {
                text: "add user to model"
                onClicked: {
                    remoteUserModel.append({"name":"David Faller" })
                }
            }
            Button {
                text: "clear model"
                onClicked: {
                    remoteUserModel.clear()
                }
            }
            Button {
                text: "remote activity"
                onClicked: {
                    remote_activity_label.visible = true;
                    remote_activity_label.text= "Controlled by David Faller";
                    activityMonitorTimer.start();
                }
            }
            Text {
                id:debugtext
                text: "platform_state:" + NavigationControl.context.platform_state
            }
            Button {
                text: "update state"
                onClicked: {
                    debugtext.text = "platform_state:" + NavigationControl.context.platform_state
                }
            }
        }

        Column {
            id: debug2
            anchors {
                left: debug1.right
                leftMargin: 10
            }

            Button {
                text: "new plat connect MV"
                onClicked: {
                    var data = { platform_name: "motor-vortex"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }

            Button {
                text: "disconnect"
                onClicked: {

                    NavigationControl.updateState(NavigationControl.events.PLATFORM_DISCONNECTED_EVENT, null)
                    var disconnect_json = {"hcs::cmd":"disconnect_platform"}
                    console.log("disonnecting the platform")
                    coreInterface.sendCommand(JSON.stringify(disconnect_json))
                }
            }
        }
    }
}
