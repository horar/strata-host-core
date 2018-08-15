import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import "qrc:/views/motor-vortex/sgwidgets"
import "js/navigation_control.js" as NavigationControl

Rectangle{
    id:container

    // Context properties that get passed when created dynamically
    property string user_id: ""

    // Hardcoded mapping
    property var userImages: {
        "dave.priscak@onsemi.com" : "dave_priscak.png",
                "david.somo@onsemi.com" : "david_somo.png",
                "daryl.ostrander@onsemi.com" : "daryl_ostrander.png",
                "paul.mascarenas@onsemi.com" : "paul_mascarenas.png",
                "blankavatar" : "blank_avatar.png"
    }

    property var userNames: {
        "dave.priscak@onsemi.com" : "Dave Priscak",
                "david.somo@onsemi.com"   : "David Somo",
                "daryl.ostrander@onsemi.com" : "Daryl Ostrander",
                "paul.mascarenas@onsemi.com" : "Paul Mascarenas",
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

    // DEBUG test butt-un to simulate signal data
    //        Button {
    //            text: "TEST"

    //            onClicked: {

    ////                // DEBUG inject test data for testing offline
    ////                var list = [
    ////                            {
    ////                                "verbose":"usb-pd",
    ////                                "uuid":"P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af",
    ////                                "connection":"view"
    ////                            },
    ////                            {
    ////                                "verbose":"bubu",
    ////                                "uuid":"P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671",
    ////                                "connection":"connected"
    ////                            },
    ////                            {
    ////                                "verbose":"motor-vortex",
    ////                                "uuid":"motorvortex1",
    ////                                "connection":"connected"
    ////                            }];

    ////                var handshake = {"list":list};
    ////                console.log("TEST platformList: ", JSON.stringify(handshake));
    ////                platformContainer.populatePlatforms(JSON.stringify(handshake));

    //                coreInterface.sendHandshake();
    //            }
    //        }

    anchors.fill: parent
    clip: true

    Image {
        id: background
        source: "qrc:/images/login-background.svg"
        height: 1080
        width: 1920
        x: (parent.width - width)/2
        y: (parent.height - height)/2
    }

    Item {
        id: upperContainer
        anchors {
            left: container.left
            right: container.right
            top: container.top
        }
        height: container.height * 0.5
        z: 2

        Item {
            id: userContainer
            anchors {
                verticalCenter: upperContainer.verticalCenter
                horizontalCenter: upperContainer.horizontalCenter
                horizontalCenterOffset: -200
            }
            height: welcomeMessage.height + user_img.height
            width: Math.max (welcomeMessage.width, user_img.width)

            Image {
                id: user_img
                sourceSize.width: 135
                height: 1.1333 * width
                anchors {
                    top : userContainer.top
                    horizontalCenter: welcomeMessage.horizontalCenter
                }
                source: "qrc:/images/" + getUserImage(user_id)
                visible: false
            }

            Rectangle {
                id: mask
                width: 135
                height: width
                radius: width/2
                visible: false
            }

            OpacityMask {
                anchors {
                    top: user_img.top
                    horizontalCenter: user_img.horizontalCenter
                }
                height: 135
                width: 135
                source: user_img
                maskSource: mask
            }

            Label {
                id: welcomeMessage
                anchors {
                    top: user_img.bottom
                    topMargin: 0
                }
                font {
                    family: franklinGothicBold.name
                    pixelSize: 32
                }
                text: getUserName(user_id)
            }
        }

        Rectangle {
            id: divider
            color: "#999"
            anchors {
                left: userContainer.right
                leftMargin: 30
                top: userContainer.top
                bottom: userContainer.bottom
            }
            width: 2
        }

        Item {
            id: platformContainer
            anchors {
                verticalCenter: userContainer.verticalCenter
                left: divider.right
                leftMargin: 30
            }
            height: strataLogo.height + platformSelector.height + platformSelector.anchors.topMargin + cbSelector.height + cbSelector.anchors.topMargin
            width: cbSelector.width

            Image {
                id: strataLogo
                width: 2 * height
                height: upperContainer.height > 264 ? 175 : 100
                anchors {
                    horizontalCenter: cbSelector.horizontalCenter
                }
                source: "qrc:/images/strata-logo.svg"
                mipmap: true;
            }

            Label {
                id: platformSelector
                text: "SELECT PLATFORM:"
                font {
                    pixelSize: 20
                    family: franklinGothicBold.name
                }
                anchors {
                    top: strataLogo.bottom
                    topMargin: 20
                    horizontalCenter: cbSelector.horizontalCenter
                }
            }

            Connections {
                target: coreInterface
                onPlatformListChanged: {
                    //console.log("platform list updated: ", list)
                    platformContainer.populatePlatforms(list)
                }
            }

            ListModel {
                id: platformListModel

                Component.onCompleted: {
                    //console.log("platformListModel:Component.onCompleted:");
                    platformContainer.populatePlatforms(coreInterface.platform_list_)
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
                 //to enable a new board UI to be shown, this list has to be edited to include the exact UUID for the boad.
                //the other half of the map will be the name of the directory that will be used to show the initial screen (e.g. usb-pd/Control.qml)
                var uuid_map = {
                    "P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af" : "usb-pd",
                    //"P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af" : "motor-vortex",
                    "P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671" : "bubu",
                    "motorvortex1" : "motor-vortex",
                    "SEC.2018.004.1.1.0.2.20180710161919.1bfacee3-fb60-471d-98f8-fe597bb222cd" : "usb-pd-multiport",
                    "SEC.2018.004.1.0.1.0.20180717143337.6828783d-b672-4fd5-b66b-370a41c035d2" : "usb-pd-multiport"    //david's new board
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

            SGComboBox {
                id: cbSelector
                anchors {
                    top: platformSelector.bottom
                    topMargin: 10
                    left: platformContainer.left
                }
                comboBoxWidth: 350
                textRole: "text"
                TextMetrics { id: textMetrics }

                model: platformListModel

                onActivated: {
                    /*
                   Determine action depending on what type of 'connection' is used
                */

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
        }
    }

    Item {
        id: lowerContainer
        anchors {
            left: container.left
            right: container.right
            bottom: container.bottom
        }
        height: container.height * 0.5
        z: 1

        Item {
            id: adContainer
            anchors {
                verticalCenter: lowerContainer.verticalCenter
                horizontalCenter: lowerContainer.horizontalCenter
            }
            height: lowerContainer.height * 0.86
            width: height / 0.53
            clip: true

            SwipeView {
                id: adSwipe
                anchors {
                    fill: parent
                }

                Image {
                    source: "qrc:/images/demo-ads/1.png"

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Qt.openUrlExternally("http://www.onsemi.com");
                        }
                    }
                }

                Image {
                    source: "qrc:/images/demo-ads/2.png"

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Qt.openUrlExternally("http://www.onsemi.com");
                        }
                    }
                }

                Image {
                    source: "qrc:/images/demo-ads/3.png"

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Qt.openUrlExternally("http://www.onsemi.com");
                        }
                    }
                }

                Image {
                    source: "qrc:/images/demo-ads/4.png"

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Qt.openUrlExternally("http://www.onsemi.com");
                        }
                    }
                }
            }

            Timer {
                interval: 3000
                running: true
                repeat: true
                onTriggered: {
                    if (adSwipe.currentIndex < 3) {
                        adSwipe.currentIndex++
                    } else {
                        adSwipe.currentIndex = 0
                    }
                }
            }

            PageIndicator {
                id: indicator

                count: adSwipe.count
                currentIndex: adSwipe.currentIndex

                anchors.bottom: adSwipe.bottom
                anchors.horizontalCenter: adSwipe.horizontalCenter
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
}
