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
            storePlatforms()
            listModel.clear()
            recentListModel.clear()
        }
    }

    Component.onDestruction: {
        storePlatforms()
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

                RowLayout {

                    Item {
                        Layout.preferredWidth: 40
                    }

                    Text {
                        Layout.preferredWidth: 310
                        text: 'Class ID'
                    }

                    Text {
                        Layout.preferredWidth: 140
                        text: "Version"
                    }

                    Text {
                        Layout.preferredWidth: 150
                        text: "Device ID"
                    }

                    Text {
                        text: "Connected"
                    }

                }

                ListView {
                    id: listView
                    model: listModel
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    Layout.maximumHeight: 300
                    clip: true
                    spacing: 5

                    delegate: RowLayout {
                        id: rowPlatform
                        Layout.fillWidth: true

                        property var platformSources: {"class_id": model.platform.class_id, "opn": model.platform.opn}
                        property int device_id: model.platform.device_id
                        property string firmware_version: model.platform.firmware_version
                        property bool connected: model.platform.connected

                        property bool hasUpdated: false

                        onPlatformSourcesChanged: {
                            if(root.visible && hasUpdated){
                                let platform = {
                                    class_id: platformSources.class_id,
                                    opn: platformSources.opn,
                                    device_id: device_id,
                                    firmware_version: firmware_version,
                                    connected: connected
                                }
                                hasUpdated = false
                                updateConnectedPlatforms(platform, model.index)
                            }
                        }

                        onFirmware_versionChanged: {
                            if(root.visible && hasUpdated){
                                let platform = {
                                    class_id: platformSources.class_id,
                                    opn: platformSources.opn,
                                    device_id: device_id,
                                    firmware_version: firmware_version,
                                    connected: connected
                                }
                                hasUpdated = false
                                updateConnectedPlatforms(platform, model.index)
                            }
                        }

                        onConnectedChanged: {
                            if(root.visible && hasUpdated){
                                let platform = {
                                    class_id: platformSources.class_id,
                                    opn: platformSources.opn,
                                    device_id: device_id,
                                    firmware_version: firmware_version,
                                    connected: connected
                                }
                                hasUpdated = false
                                updateConnectedPlatforms(platform, model.index)
                            }
                        }

                        onDevice_idChanged: {
                            if(root.visible && device_id > -1) {
                                deviceIdComboBox.currentIndex = device_id
                                deviceIdComboBox.contentItem.text = deviceFilterModel.get(device_id).device
                                deviceFilterModel.setDeviceInUse(device_id)
                                hasUpdated = false
                            }
                        }

                        Rectangle {
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: Layout.preferredHeight
                            color: "red"

                            SGIcon {
                                source:"qrc:/sgimages/times.svg"
                                anchors.centerIn: parent
                                width: 30
                                height: width

                                iconColor: "white"
                            }

                            MouseArea {
                                id: closeArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    rowPlatform.connected = false
                                    deletePlatform(model.index)
                                }
                            }
                        }

                        Item {
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 310

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0
                                SGTextField {
                                    id: classIDField
                                    placeholderText: "Class Id..."
                                    text: rowPlatform.platformSources.class_id
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 250

                                    property bool onHasChanged: false

                                    onTextChanged: {
                                        if(root.visible && rowPlatform.platformSources.class_id!== text && text !== ""){
                                            onHasChanged = true
                                        }
                                    }

                                    onEditingFinished: {
                                        if(onHasChanged){
                                            rowPlatform.hasUpdated = true
                                            rowPlatform.platformSources = {"class_id": text, "opn":checkForCustomId(text) ? "Custom Platform" :rowPlatform.platformSources.opn}
                                            onHasChanged = false
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.preferredHeight: 40
                                    Layout.preferredWidth: 60
                                    border.color: "lightGrey"
                                    border.width: 0.5
                                    SGIcon {
                                        width: 55
                                        height: 35
                                        anchors.centerIn: parent
                                        source: "qrc:/sgimages/chevron-up.svg"
                                        iconColor: "lightGrey"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true

                                        onClicked: {
                                            popUp.open()
                                        }
                                    }
                                }
                            }

                            Popup {
                                id: popUp
                                width: 310
                                height: 300
                                y: parent.y - height

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 5

                                    RowLayout {
                                        Layout.alignment: Qt.AlignHCenter
                                        spacing: 2

                                        SGButton {
                                            Layout.preferredHeight: 40
                                            Layout.preferredWidth: 140
                                            text: "Platform Selection List"
                                            enabled: popUpView.model !== classModel

                                            onClicked: {
                                                popUpView.model = classModel
                                            }
                                        }

                                        SGButton {
                                            Layout.preferredHeight: 40
                                            Layout.preferredWidth: 140
                                            text: "Recent Platform List"
                                            enabled: popUpView.model !== recentListModel
                                            onClicked: {
                                                popUpView.model = recentListModel
                                            }
                                        }
                                    }

                                    Rectangle {
                                        color: "grey"
                                        Layout.preferredHeight: 1
                                        Layout.fillWidth: true
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                    }

                                    ListView {
                                        id: popUpView
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        model: classModel
                                        clip: true

                                        ScrollBar.vertical: ScrollBar {
                                            active: true
                                        }

                                        delegate: Item {
                                            height: 40
                                            width: parent.width
                                            SGText {
                                                id: opnText
                                                color: delegateArea.containsMouse ? "#888" : "black"
                                                anchors.left: parent.left
                                                anchors.top: parent.top
                                                text: model.platform.opn
                                                leftPadding: 5
                                            }

                                            SGText {
                                                id: classText
                                                color: delegateArea.containsMouse ? "#888" : "#333"
                                                anchors.left: parent.left
                                                anchors.top: opnText.bottom
                                                text: model.platform.class_id
                                                leftPadding: 10
                                            }

                                            MouseArea {
                                                id: delegateArea
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true

                                                onClicked: {
                                                    popUpView.setPlatform({class_id: model.platform.class_id, opn: model.platform.opn})
                                                    popUp.close()
                                                }
                                            }
                                        }

                                        function setPlatform(platform){
                                            classIDField.text = platform.class_id
                                            rowPlatform.hasUpdated = true
                                            rowPlatform.platformSources = platform
                                        }
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

                                text: rowPlatform.firmware_version

                                property bool onHasChanged: false

                                onTextChanged: {
                                    if(root.visible && rowPlatform.firmware_version !== text && text !== ""){
                                        onHasChanged = true
                                    }
                                }

                                onEditingFinished: {
                                    if(onHasChanged){
                                        rowPlatform.hasUpdated = true
                                        rowPlatform.firmware_version = text
                                        onHasChanged = false
                                    }
                                }
                            }
                        }

                        SGComboBox {
                            id: deviceIdComboBox
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 150
                            model: deviceFilterModel
                            placeholderText: "device_id 0"
                            textRole: null
                            currentIndex: -1
                            enabled: !rowPlatform.connected

                            delegate: SGText {
                                id: deviceText
                                color: deviceArea.containsMouse ? "#888" : enabled ? "black" : "#bbb"

                                text: model.device
                                leftPadding: 5
                                enabled: !deviceFilterModel.checkIfInUse(model.index) && model.index !== rowPlatform.device_id

                                MouseArea {
                                    id: deviceArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    enabled: parent.enabled

                                    onClicked: {
                                        deviceIdComboBox.setDevice(model.index)
                                        deviceIdComboBox.popup.close()
                                    }
                                }
                            }

                            function setDevice(index){
                                if(rowPlatform.device_id !== -1){
                                    deviceFilterModel.enableDeviceNotInUse(rowPlatform.device_id)
                                }
                                rowPlatform.hasUpdated = true
                                rowPlatform.device_id = index
                                currentIndex = index
                                contentItem.text = deviceFilterModel.get(index).device
                                deviceFilterModel.setDeviceInUse(index)
                            }
                        }

                        Switch {
                            id: connectSwitch
                            checked: rowPlatform.connected
                            enabled: rowPlatform.platformSources.class_id !== "" && rowPlatform.device_id > -1 && rowPlatform.firmware_version !== ""
                            onCheckedChanged: {
                                rowPlatform.hasUpdated = true
                                rowPlatform.connected = checked
                           }
                        }
                    }
                }

                Button {
                    text: "Add Platform"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignLeft
                    leftPadding: 40

                    onClicked: {
                        listModel.append({platform:{class_id: "", opn: "" ,device_id: -1, firmware_version: "0.0.2", connected: false}})
                    }
                }
            }
        }

        Settings {
            id: localPlatformSettings
            category: "LocalPlatformList"
        }
        // will store recent used platforms
        Settings {
            id: storeDeviceList
            category: "StoreDevicesList"
            fileName: "storedDevices"
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
    // The ListModel for the connected platforms
    ListModel {
        id: listModel
    }

    ListModel {
        id: recentListModel
    }

    // The model for the PlatformSelection platforms {class_id and opn}
    ListModel {
        id: classModel
    }
    // The model for the deviceIdComboBox
    ListModel {
        id: deviceModel
    }
    // The model that stores which device_id's are in Use
    SGSortFilterProxyModel {
        id: deviceFilterModel
        sourceModel: deviceModel

        function checkIfInUse(index) {
            const item = sourceModel.get(index)
            if(item.inUse){
                return true
            }
            return false
        }

        function setDeviceInUse(index) {
            const item = sourceModel.get(index)
            item.inUse = true
            sourceModel.set(index, item)
        }

        function enableDeviceNotInUse(index) {
            const item = sourceModel.get(index)
            item.inUse = false
            sourceModel.set(index, item)
        }
    }

    // Loads the PlatformSelectionModel, a device model, and prepends the classModel with any saved custom platforms
    function initialModelLoad(){

        for(var i = 0; i < PlatformSelection.platformSelectorModel.count; i++){
            classModel.append({platform: {class_id: PlatformSelection.platformSelectorModel.get(i).class_id, opn: PlatformSelection.platformSelectorModel.get(i).opn}})
        }

        for(var j = 0; j < 10; j++){
            deviceModel.append({device: `device_id ${j}`, inUse: false})
        }

        if(storeDeviceList.value("recent-platforms") !== undefined){
            const storedPlatforms = JSON.parse(storeDeviceList.value("recent-platforms"))
            const platforms = JSON.parse(storedPlatforms.platforms)
            if(platforms.length > 0){
                for(var x = 0; x < platforms.length; x++){
                    listModel.append({platform: {class_id: platforms[x].platform.class_id, opn: platforms[x].platform.opn, device_id: platforms[x].platform.device_id, firmware_version: platforms[x].platform.firmware_version, connected: false}})
                    recentListModel.append({platform: {class_id: platforms[x].platform.class_id, opn: platforms[x].platform.opn}})
                }
            } else {
                listModel.append({platform: {class_id: "", opn: "" ,device_id: -1, firmware_version: "0.0.2", connected: false}})
            }
        } else {
            listModel.append({platform: {class_id: "", opn: "" ,device_id: -1, firmware_version: "0.0.2", connected: false}})
        }
    }
    // Loads the new platform class_id, and stores the recently used platform or checks to see if it is a custom platform and stores it to the custom platforms
    function updateConnectedPlatforms(platform,index){
        let list = []
        let injectList = {
            "list": list,
            "type": "connected_platforms"
        }

        PlatformSelection.parseConnectedPlatforms(JSON.stringify(injectList))
        listModel.set(index,{platform:platform})

        for (var i = 0; i < listModel.count; i++){
            const updatedPlatform = listModel.get(i).platform
            if(updatedPlatform.connected){
                list.push({
                    "class_id": updatedPlatform.class_id,
                    "device_id": updatedPlatform.device_id + Constants.DEBUG_DEVICE_ID,
                    "firmware_version": updatedPlatform.firmware_version
                })
            }
        }

        injectList = {
            "list": list,
            "type": "connected_platforms"
        }
        if(recentListModel.count > 0  && platform.connected){
            let flag = false
            for(var j = 0; j < recentListModel.count; j++){
                if(recentListModel.get(j).platform.class_id === platform.class_id){
                    flag = true
                    break
                }
            }
            if(!flag){
                recentListModel.append({platform:{class_id: platform.class_id, opn: platform.opn}})
            }
        } else if(platform.connected){
            recentListModel.append({platform:{class_id: platform.class_id, opn: platform.opn}})
        }

        PlatformSelection.parseConnectedPlatforms(JSON.stringify(injectList))
    }

    // Removes the index in both the stored-platforms and the listModel or remove the index in the listModel
    function deletePlatform(index){
        listModel.remove(index)

    }

    // Checks for a custom class_id
    function checkForCustomId(classId){
        for(var i = 0; i < PlatformSelection.platformSelectorModel.count; i++){
            if(classId === PlatformSelection.platformSelectorModel.get(i).class_id){
                return false
            }
        }
        return true
    }
    // Stores the most recently used platforms
    function storePlatforms() {
        let platforms = []
        for(var i = 0; i < listModel.count; i++){
            platforms.push({platform: listModel.get(i).platform})
        }
        storeDeviceList.setValue("recent-platforms",JSON.stringify({platforms: JSON.stringify(platforms)}))
    }
}


