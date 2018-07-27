import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Controls.Styles 1.4

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
////                platformSelectorContainer.populatePlatforms(JSON.stringify(handshake));

//                coreInterface.sendHandshake();
//            }


//        }

    anchors.fill: parent
    color: "#d9dfe1"
    gradient: Gradient {
        GradientStop {
            position: 0
            color: "#d9dfe1"
        }

        GradientStop {
            position: 1
            color: "#000000"
        }
    }

    Image {
        id: user_img
        width: 135
        height: 153
        anchors.horizontalCenter: messageContainer.horizontalCenter
        source: "qrc:/images/" + getUserImage(user_id)
        anchors.top: messageContainer.bottom
        anchors.topMargin: 20
    }


    Image {
        id: onIcon
        anchors.horizontalCenter: container.horizontalCenter
        anchors.top: container.top
        anchors.topMargin: 100
        width: 123
        height: 118
        source: "qrc:/images/icons/onLogoGrey.svg"
    }
    Rectangle {
        id: messageContainer
        anchors.top : onIcon.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: container.horizontalCenter
        width: 375
        height: 47
        color: "transparent"

        Label{
            id: welcomeMessage
            //width: 168
            //height: 40
            font.pixelSize: 36
            color: "white"
            text: "Welcome " + getUserName(user_id) + "!"
            anchors.centerIn: messageContainer
        }
    }
    Rectangle {
        id: platformSelectorContainer
        width: 430
        height: 69
        color: "transparent"
        anchors.horizontalCenter: onIcon.horizontalCenter
        anchors.top: user_img.bottom
        anchors.topMargin: 20
        Label {
            id: platformSelector
            width: 262
            height: 41
            text: "Select Platform:"
            font.pointSize: 21
            color: "white"
        }

        Connections {
            target: coreInterface
            onPlatformListChanged: {
                //console.log("platform list updated: ", list)
                platformSelectorContainer.populatePlatforms(list)
            }
        }

        ListModel {
            id: platformListModel

            Component.onCompleted: {
                //console.log("platformListModel:Component.onCompleted:");
                platformSelectorContainer.populatePlatforms(coreInterface.platform_list_)
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
                "SEC.2018.004.1.1.0.2.20180710161919.1bfacee3-fb60-471d-98f8-fe597bb222cd" : "usb-pd-multiport"
            }

            platformListModel.clear()

            // Parse JSON
            try {
                //console.log("populatePlaforms: ", platform_list_json)
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

        ComboBox {
            id: cbSelector
            anchors.left: platformSelector.right
            width: 350
            textRole: "text"
            TextMetrics{ id: textMetrics}

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
