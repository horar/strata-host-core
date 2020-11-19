import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.1
import tech.strata.commoncpp 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/constants.js" as Constants

Window {
    id: root
    width: 800
    height: mainColumn.implicitHeight + 20
    maximumWidth: width
    maximumHeight: height
    minimumWidth: width
    minimumHeight: height
    title: "Local platform list manipulation"

    onVisibleChanged: {
        if(visible) {
            initialModelLoad()
        } else {
            deviceModel.clear()
            classModel.clear()
        }
    }

    ColumnLayout {
        id: mainColumn
        spacing: 5
        anchors.centerIn: parent

        Rectangle {
            id: alertRect

            width: root.width * 0.75
            height: 0
            Layout.alignment: Qt.AlignHCenter

            color: "red"
            visible: height > 0
            clip: true

            SGIcon {
                id: alertIcon
                source: Qt.colorEqual(alertRect.color, "red") ? "qrc:/sgimages/exclamation-circle.svg" : "qrc:/sgimages/check-circle.svg"
                anchors {
                    left: alertRect.left
                    verticalCenter: alertRect.verticalCenter
                    leftMargin: alertRect.height/2 - height/2
                }
                height: 30
                width: 30
                iconColor: "white"
            }

            Text {
                id: alertText

                anchors {
                    left: alertIcon.right
                    right: alertRect.right
                    rightMargin: 5
                    verticalCenter: alertRect.verticalCenter
                }

                font {
                    pixelSize: 10
                    family: Fonts.franklinGothicBold
                }
                wrapMode: Label.WordWrap

                horizontalAlignment:Text.AlignHCenter
                text: ""
                color: "white"
            }
        }

        Timer {
            id: animationCloseTimer

            repeat: false
            interval: 4000

            onTriggered: {
                hideAlertAnimation.start()
            }
        }

        NumberAnimation{
            id: alertAnimation
            target: alertRect
            property: "Layout.preferredHeight"
            to: 40
            duration: 100

            onFinished: {
                animationCloseTimer.start()
            }
        }

        NumberAnimation{
            id: hideAlertAnimation
            target: alertRect
            property: "Layout.preferredHeight"
            to: 0
            duration: 100
            onStarted: alertText.text = ""
        }

        SGText {
            text: "Local platform list"
            fontSizeMultiplier: 1.6
            Layout.alignment: Qt.AlignLeft

            font {
                family: Fonts.franklinGothicBook
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter

            Row {
                id: loadRow

                Layout.alignment: Qt.AlignHCenter
                spacing: 1

                Button {
                    id: loadButton

                    text: "Load local platform list"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onContainsMouseChanged: {
                            parent.highlighted = containsMouse
                        }

                        onClicked: {
                            fileDialog.open()
                        }
                    }

                    FileDialog {
                        id: fileDialog

                        title: "Platform List Controls"
                        folder: shortcuts.home
                        selectExisting: true
                        selectMultiple: false
                        nameFilters: ["JSON files (*.json)"]

                        onAccepted: {
                            let path = SGUtilsCpp.urlToLocalFile(fileDialog.fileUrl);
                            let platforms = PlatformSelection.getLocalPlatformList(path)

                            // if we get a valid JSON file with a platform list, then either append or replace
                            if (platforms.length > 0) {
                                alertText.text = "Successfully added a local platform list."
                                alertRect.color = "#57d445"
                                alertAnimation.start()

                                // Option 0 is append, 1 is replace
                                if (loadOptionComboBox.currentText === "Append") {
                                    PlatformSelection.setLocalPlatformList(platforms);
                                    console.info("Appending a local platform list.")
                                } else if (loadOptionComboBox.currentText === "Replace") {
                                    PlatformSelection.setLocalPlatformList([]);
                                    PlatformSelection.platformSelectorModel.clear();
                                    PlatformSelection.setLocalPlatformList(platforms);
                                    console.info("Replacing dynamic platform list with a local one.")
                                }
                            } else {
                                alertText.text = "Local platform list file has invalid JSON."
                                alertRect.color = "red"
                                alertAnimation.start()
                            }
                        }
                    }
                }

                SGComboBox {
                    id: loadOptionComboBox

                    height: loadButton.height

                    model: ["Append", "Replace"]
                    currentIndex: localPlatformSettings.value("mode", "append") === "append" ? 0 : 1
                    dividers: true

                    onCurrentIndexChanged: {
                        localPlatformSettings.setValue("mode", currentIndex === 0 ? "append" : "replace")
                    }
                }
            }

            Button {
                id: removeButton

                Layout.alignment: Qt.AlignHCenter
                text: "Remove local platform list"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onContainsMouseChanged: {
                        parent.highlighted = containsMouse
                    }

                    onClicked: {
                        mainColumn.removeLocalPlatformList()
                    }
                }
            }

            Button {
                id: resetButton

                width: removeButton.width
                Layout.alignment: Qt.AlignHCenter
                text: "Reset platform list"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onContainsMouseChanged: {
                        parent.highlighted = containsMouse
                    }

                    onClicked: {
                        mainColumn.removeLocalPlatformList()
                        PlatformSelection.getPlatformList()
                    }
                }
            }
        }

        SGText {
            text: `Manipulate "available" flags`
            fontSizeMultiplier: 1.6
            Layout.alignment: Qt.AlignLeft
            Layout.topMargin: 10
            font {
                family: Fonts.franklinGothicBook
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter

            Repeater {
                id: repeat
                model: ['documents', 'order', 'control', 'unlisted']
                delegate: RowLayout{
                    id: row
                    spacing: 5
                    SGButtonStrip {
                        model: [true, false]
                        checkedIndices: 0
                        onClicked: {
                            mainColumn.manipulateFlags(model[index],modelData)
                        }
                    }
                    SGText {
                        text: modelData
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            SGButton {
                id: reset
                Layout.alignment: Qt.AlignLeft
                Layout.preferredWidth: 200
                enabled: false
                text: "Reset flags"
                onPressed: {
                    for (var i = 0; i < repeat.count; i++){
                        const item = repeat.itemAt(i).childAt(0,0)
                        item.checkedIndices = 0
                    }

                    reset.enabled = false
                    PlatformSelection.getPlatformList()
                }
            }
        }

        SGAlignedLabel {
            text: "Inject connected class_id:"
            Layout.topMargin: 10
            fontSizeMultiplier: 1.5
            target: injectPlatform
            ColumnLayout {
                id: injectPlatform

                property var list: []
                RowLayout {
                    id: rowPlatform
                    Button {
                        text: "Inject"
                        Layout.preferredHeight: 40
                        enabled: device_id.currentIndex !== -1 && class_id.classId !== ""
                        onClicked: {
                            loadAndStorePlatform({class_id: class_id.classId, opn: class_id.opn},textField.text, checkForCustomId(class_id.classId))
                        }
                    }

                    SGComboBox {
                        id: class_id
                        Layout.preferredHeight: 40
                        Layout.preferredWidth: 300
                        model: classModel
                        placeholderText: "class_id..."
                        editable: true

                        property string classId: ""
                        property string opn: ""

                        onEditTextChanged: {
                            classId = editText
                        }


                        onClassIdChanged: {
                            class_id.contentItem.text = classId

                        }

                        MouseArea {
                            anchors.fill: parent

                            acceptedButtons: Qt.RightButton

                            onClicked: {
                                menu.open()
                            }
                        }

                        Menu{
                            id: menu
                            width: parent.width
                            y: parent.y - parent.height
                            MenuItem {
                                text: "Clear custom platforms"

                                onClicked: {
                                    storeDeviceList.customPlatforms = []
                                    storeDeviceList.setValue("stored-platforms", {platforms: storeDeviceList.customPlatforms})
                                    deviceModel.clear()
                                    classModel.clear()
                                    initialModelLoad()
                                }
                            }
                        }

                        delegate: ListView {
                            model: classModel.platform
                            height: 40
                            width: parent.width
                            SGText {
                                id: opnText
                                color: delegateArea.containsMouse ? "#888" : "black"
                                anchors.left: parent.left
                                anchors.top: parent.top
                                text: modelData.opn
                                leftPadding: 5
                            }

                            SGText {
                                id: classText
                                color: delegateArea.containsMouse ? "#888" : "#333"
                                anchors.left: parent.left
                                anchors.top: opnText.bottom
                                text: modelData.class_id
                                leftPadding: 10
                            }

                            MouseArea {
                                id: delegateArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                acceptedButtons: Qt.LeftButton | Qt.RightButton

                                onClicked: {
                                    if(mouse.button === Qt.LeftButton) {
                                        class_id.setId(modelData.class_id)
                                        class_id.popup.close()
                                    }
                                }
                            }

                        }

                        function setId(class_){
                            for(var i = 0; i < classModel.count; i++){
                                if(class_ === classModel.get(i).platform.class_id){
                                    class_id.currentIndex = i
                                    classId = class_
                                    opn = classModel.get(i).platform.opn
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.preferredHeight: 40
                        Layout.preferredWidth: 140
                        color: "transparent"
                        border.width: 0.5
                        border.color: "lightgrey"
                        SGText {
                            id: textBox
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "ver."
                            leftPadding: 5
                            rightPadding: 5
                        }

                        SGTextField {
                            id: textField
                            anchors.left: textBox.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            placeholderText: "firmware_version"

                            text: "0.0.2"
                        }
                    }

                    SGComboBox {
                        id: device_id
                        Layout.preferredHeight: 40
                        Layout.preferredWidth: 150
                        model: deviceModel
                        placeholderText: "device id"

                        delegate: SGText {
                            color: deviceArea.containsMouse ? "#888" : "black"

                            text: modelData
                            leftPadding: 5


                            MouseArea {
                                id: deviceArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    device_id.setDevice(modelData)
                                    device_id.popup.close()
                                }
                            }
                        }

                        function setDevice(device){
                            for(var i = 0; i < deviceModel.count; i++){
                                if(device === deviceModel.get(i).device){
                                    device_id.currentIndex = i
                                }
                            }
                        }
                    }
                }

                Button {
                    text: "Disconnect All Platforms"
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        injectPlatform.list = []
                        let list = {
                            "list": [],
                            "type":"connected_platforms"
                        }

                        PlatformSelection.parseConnectedPlatforms(JSON.stringify(list))
                    }
                }
            }
        }

        Settings {
            id: localPlatformSettings
            category: "LocalPlatformList"
        }

        Settings {
            id: storeDeviceList
            category: "StoreDevicesList"
            fileName: "storedDevices.ini"
            // will store custom platforms
            property var customPlatforms: []

        }

        function removeLocalPlatformList() {
            PlatformSelection.setLocalPlatformList([])
            localPlatformSettings.setValue("path", "")
        }

        function manipulateFlags(bool,flag){
            for(var i = 0; i < PlatformSelection.platformSelectorModel.count ; i+=1){
                const platformItem = PlatformSelection.platformSelectorModel.get(i)
                const available = PlatformSelection.classMap[platformItem.class_id].original_listing.available
                available[flag] = bool
                PlatformSelection.classMap[platformItem.class_id].original_listing.available = available
                const platform = PlatformSelection.classMap[platformItem.class_id].original_listing
                PlatformSelection.platformSelectorModel.set(i, platform);
            }
            if(!reset.enabled){
                reset.enabled = true
            }
        }
    }

    ListModel {
        id: classModel
    }

    ListModel {
        id: deviceModel
    }

    function parseCustomSavedIds(){
        if(storeDeviceList.value("stored-platforms") !== undefined){
            const storedPlatform = storeDeviceList.value("stored-platforms")
            if(storedPlatform.hasOwnProperty("platforms")){
                const customPlatforms = storedPlatform.platforms
                for(var i = 0; i < customPlatforms.length; i++){
                    if(customPlatforms[i].platform.custom){
                        classModel.append({platform: {class_id: customPlatforms[i].platform.class_id, opn: "Custom Platform"}})
                    }
                }
            }
        }
    }
    // Loads the PlatformSelectionModel, a device model, and prepends the classModel with any saved custom platforms
    function initialModelLoad(){
        parseCustomSavedIds()

        for(var i = 0; i < PlatformSelection.platformSelectorModel.count; i++){
                classModel.append({platform: {class_id: PlatformSelection.platformSelectorModel.get(i).class_id, opn: PlatformSelection.platformSelectorModel.get(i).opn}})
        }

        for(var j = 0; j < 10; j++){
            deviceModel.append({device: `device_id ${j}`})
        }

        device_id.currentIndex = 0

        if(storeDeviceList.value("stored-platform") !== undefined){
            if(storeDeviceList.value("stored-platform").hasOwnProperty("platform")){
                class_id.classId = storeDeviceList.value("stored-platform").platform.class_id
                class_id.opn = storeDeviceList.value("stored-platform").platform.opn
                if(class_id.classId){
                    for(var n = 0; n < classModel.count; n++){
                        if(class_id.classId === classModel.get(n).platform.class_id){
                            class_id.contentItem.text = class_id.classId
                            textField.text = storeDeviceList.value("stored-platform").platform.firmware_version
                            break;
                        }
                    }
                }
            }
        }
    }
    // loads the new platform class_id, and stores the recently used platform or checks to see if it is a custom platform and stores it to the custom platforms
    function loadAndStorePlatform(platform, firmwareVer, custom){
        const platforms = classModel
        for(var i = 0; i < platforms.count; i++){
            if(platform.class_id === platforms.get(i).platform.class_id && !custom){
                injectPlatform.list.push({
                                              "class_id": platform.class_id,
                                              "device_id": Constants.DEBUG_DEVICE_ID + device_id.currentIndex,
                                              "firmware_version": firmwareVer
                                          })
                let list = {
                    "list": injectPlatform.list,
                    "type":"connected_platforms"

                }

                PlatformSelection.parseConnectedPlatforms(JSON.stringify(list))
                storeDeviceList.setValue("stored-platform",{platform: {class_id: platform.class_id, opn: platform.opn, firmware_version: firmwareVer, custom: custom } })
                break
            } else {
                injectPlatform.list.push({
                                              "class_id": platform.class_id,
                                              "device_id": Constants.DEBUG_DEVICE_ID + device_id.currentIndex,
                                              "firmware_version": firmwareVer
                                          })
                let list = {
                    "list": injectPlatform.list,
                    "type":"connected_platforms"

                }

                PlatformSelection.parseConnectedPlatforms(JSON.stringify(list))
                storeDeviceList.setValue("stored-platform",{platform: {class_id: platform.class_id, opn: "Custom Platform", firmware_version: firmwareVer, custom: custom } })

                storeDeviceList.customPlatforms.push({platform: {class_id: platform.class_id, opn: "Custom Platform", firmware_version: firmwareVer, custom: custom }})
                storeDeviceList.setValue("stored-platforms",{platforms: storeDeviceList.customPlatforms})
                break
            }
        }
    }
    // checks for a custom class_id
    function checkForCustomId(classId){
        for(var i = 0; i < PlatformSelection.platformSelectorModel.count; i++){
            if(classId === PlatformSelection.platformSelectorModel.get(i).class_id){
                return false
            }
        }
        return true
    }

}

