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
    width: 600
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
            x: root.width / 2 - width / 2

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
                RowLayout {
                    id: rowPlatform
                    Button {
                        text: "Inject"
                        Layout.preferredHeight: 35
                        onClicked: {
                            loadAndStorePlatform(class_id.classId)
                        }
                    }

                    SGComboBox {
                        id: class_id
                        Layout.preferredHeight: 35
                        Layout.preferredWidth: 300
                        model: classModel
                        placeholderText: "class_id..."
                        editable: true

                        property string classId: ""

                        onEditTextChanged: {
                            classId = editText
                        }

                        delegate: SGText {
                            color: delegateArea.containsMouse ? "#888" : "black"

                            text: modelData
                            leftPadding: 5

                            MouseArea {
                                id: delegateArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    class_id.setId(modelData)
                                    class_id.popup.close()
                                }
                            }

                        }

                        function setId(class_){

                            for(var i = 0; i < classModel.count; i++){
                                if(class_ === classModel.get(i).platform){
                                    class_id.currentIndex = i
                                    classId = class_
                                }
                            }
                        }
                    }

                    SGComboBox {
                        id: device_id
                        Layout.preferredHeight: 35
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
                    Layout.preferredHeight: 35
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        if(class_id.currentIndex > -1){
                            PlatformSelection.disconnectPlatform(PlatformSelection.platformSelectorModel.get(class_id.currentIndex))
                        }
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

    function initialModelLoad(){
        for(var i = 0; i < PlatformSelection.platformSelectorModel.count; i++){
            classModel.append({platform: PlatformSelection.platformSelectorModel.get(i).class_id})
            deviceModel.append({device:`device_id ${i}`})
        }

        if(storeDeviceList.value("stored-platform") !== undefined && storeDeviceList.value("stored-platform").hasOwnProperty("device_id") && storeDeviceList.value("stored-platform").hasOwnProperty("class_id")){
            device_id.currentIndex = storeDeviceList.value("stored-platform").device_id
            class_id.currentIndex = storeDeviceList.value("stored-platform").class_id
            class_id.classId = PlatformSelection.platformSelectorModel.get(class_id.currentIndex).class_id
        }
    }

    function loadAndStorePlatform(classId){
        const platforms = PlatformSelection.platformSelectorModel
        for(var i = 0; i < platforms.count; i++){
            if(classId === platforms.get(i).class_id){
                let list = {
                    "list": [
                        {
                            "class_id": classId,
                            "device_id": Constants.DEBUG_DEVICE_ID + device_id.currentIndex,
                            "firmware_version":platforms.get(i).firmware_version
                        }
                    ],
                    "type":"connected_platforms"

                }

                PlatformSelection.parseConnectedPlatforms(JSON.stringify(list))
                storeDeviceList.setValue("stored-platform",{device_id: device_id.currentIndex, class_id: class_id.currentIndex})
            } else {
                if(classId !== ""){
                    let list =
                            {
                                "class_id": classId,
                                "device_id": Constants.DEBUG_DEVICE_ID + device_id.currentIndex,
                                "firmware_version":platforms.get(i).firmware_version,
                                "type":"connected_platforms"
                            }



                    PlatformSelection.addConnectedPlatform(JSON.stringify(list))
                    PlatformSelection.platformSelectorModel.append(list)
                    storeDeviceList.setValue("stored-platform",{device_id: device_id.currentIndex, class_id: class_id.currentIndex})
                }
            }
        }
    }
}

