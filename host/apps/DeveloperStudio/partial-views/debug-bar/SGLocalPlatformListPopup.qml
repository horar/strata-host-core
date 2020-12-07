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

            for(var i = 0; i < listModel.count; i++){
                unloadAndRemovePlatform(listModel.get(i).class_id)
            }

            deviceModel.clear()
            classModel.clear()
            listModel.clear()
            currDeviceModel.clear()
            injectPlatform.list = []
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

                        property string class_id: model.class_id
                        property string opn: model.opn
                        property int device_id: model.device_id
                        property string firmware_version: model.firmware_version

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
                                    unloadAndRemovePlatform(platformsComboBox.classId)
                                    for(var i = 0; i < currDeviceModel.count; i++){
                                        if(currDeviceModel.get(i).device_id === device_id.currentIndex){
                                            currDeviceModel.remove(i)
                                        }
                                    }

                                    deletePlatform(model.index)
                                }

                            }
                        }

                        SGComboBox {
                            id: platformsComboBox
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 310
                            model: classModel
                            editable: true
                            textRole: null
                            wheelEnabled: true

                            property string classId: rowPlatform.class_id
                            property string opn: rowPlatform.opn

                            onClassIdChanged: {
                                platformsComboBox.contentItem.classId = classId
                            }

                            contentItem: RowLayout{
                                anchors.fill: parent
                                spacing: 0

                                property string classId: platformsComboBox.classId

                                SGTextField {
                                    placeholderText: "class_id..."
                                    text: parent.classId
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40

                                    onTextChanged: {
                                        platformsComboBox.classId = text
                                    }

                                    onEditingFinished: {
                                        if(model.connected && platformsComboBox.classId !== "" && deviceIdComboBox.currentIndex !== -1){
                                           changeAndReplacePlatform({class_id: platformsComboBox.classId, opn: platformsComboBox.opn}, deviceIdComboBox.currentIndex, rowPlatform.firmware_version)
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.preferredHeight: 40
                                    Layout.preferredWidth: 70
                                    border.color: "lightGrey"
                                    border.width: 0.5

                                    color: "white"

                                    SGIcon {
                                        source: "qrc:/sgimages/chevron-down.svg"
                                        iconColor: "lightGrey"
                                        anchors.centerIn: parent
                                        width: 60
                                        height: 25
                                    }

                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            if(!platformsComboBox.popup.opened){
                                                platformsComboBox.popup.open()
                                            } else {
                                                platformsComboBox.popup.close()
                                            }
                                        }
                                    }
                                }
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
                                        storeDeviceList.setValue("custom-platforms", {platforms: storeDeviceList.customPlatforms})
                                        deviceModel.clear()
                                        classModel.clear()
                                        initialModelLoad()
                                    }
                                }
                            }

                            delegate: Item {
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
                                            platformsComboBox.setId(modelData.class_id)
                                            platformsComboBox.popup.close()
                                        }
                                    }
                                }
                            }

                            function setId(class_){
                                for(var i = 0; i < classModel.count; i++){
                                    if(class_ === classModel.get(i).platform.class_id){
                                        platformsComboBox.currentIndex = i
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

                                text: rowPlatform.firmware_version

                                onTextChanged: {
                                    rowPlatform.firmware_version = text
                                }

                                onEditingFinished: {
                                    if(model.connected && platformsComboBox.classId !== "" && deviceIdComboBox.currentIndex !== -1){
                                          changeAndReplacePlatform({class_id: platformsComboBox.classId, opn: platformsComboBox.opn}, deviceIdComboBox.currentIndex, rowPlatform.firmware_version)
                                    }
                                }
                            }
                        }

                        SGComboBox {
                            id: deviceIdComboBox
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 150
                            model: deviceModel
                            placeholderText: "device_id..."
                            textRole: null
                            currentIndex: -1


                            delegate: SGText {
                                id: deviceText
                                color: deviceArea.containsMouse ? "#888" : enabled ? "black" : "#bbb"

                                text: modelData
                                leftPadding: 5
                                enabled: deviceIdComboBox.checkIfNotUsed(model.index)

                                MouseArea {
                                    id: deviceArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    enabled: parent.enabled


                                    onClicked: {
                                        deviceIdComboBox.setDevice(modelData)
                                        deviceIdComboBox.popup.close()
                                    }
                                }
                            }

                            function setDevice(device){

                                for(var i = 0; i < deviceModel.count; i++){
                                    if(device === deviceModel.get(i).device){
                                        if(checkIfNotUsed(i)) {
                                            if(currDeviceModel.count === listModel.count){
                                                for( var n = 0; n < currDeviceModel.count; n++){
                                                    if(currDeviceModel.get(n).device_id === device_id.currentIndex){
                                                        currDeviceModel.set(n, {device_id: i})
                                                    }
                                                }
                                            } else {
                                                currDeviceModel.append({device_id: i})
                                            }
                                            deviceIdComboBox.currentIndex = i
                                            break
                                        } else {
                                            for (var j = 0; j < currDeviceModel.count; j++){
                                                if(currDeviceModel.get(j).device_id === device_id.currentIndex){
                                                    currDeviceModel.remove(j)
                                                    currDeviceModel.set(j, {device_id: i})
                                                    deviceIdComboBox.currentIndex = i
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                            } 

                            function checkIfNotUsed(device_id) {
                                for(var i = 0; i < currDeviceModel.count; i++){
                                    if(currDeviceModel.get(i).device_id === device_id){
                                        return false
                                    }
                                }
                                return true
                            }
                        }

                        Switch {
                            checked: model.connected
                            enabled: deviceIdComboBox.currentIndex >= 0 && textField.text !== "" && deviceIdComboBox.classId !== ""
                            onCheckedChanged: {
                                model.connected = checked
                                if(model.connected){
                                    loadAndStorePlatform({class_id: platformsComboBox.classId, opn: platformsComboBox.opn},deviceIdComboBox.currentIndex,rowPlatform.firmware_version, checkForCustomId(class_id.classId))
                                } else {
                                    unloadAndRemovePlatform(platformsComboBox.classId)
                                }
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
                        listModel.append({class_id: "", opn: "" ,device_id: 0, firmware_version: "0.0.2", connected: false})
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
            fileName: "storedDevices"
            // will store custom platforms
            property var customPlatforms: []
            property var storedPlatforms: []

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
    // The model for the PlatformSelection platforms {class_id and opn}
    ListModel {
        id: classModel
    }
    // The model for the deviceIdComboBox
    ListModel {
        id: deviceModel
    }
    // The model that stores which device_id's are in Use
    ListModel {
        id: currDeviceModel
    }

    // Parses and adds Custom ID's to the classModel
    function parseCustomSavedIds(){
        if(storeDeviceList.value("custom-platforms") !== undefined){
            const storedPlatform = storeDeviceList.value("custom-platforms")
            if(storedPlatform.hasOwnProperty("platforms")){
                const customPlatforms = storedPlatform.platforms
                storeDeviceList.customPlatforms = storedPlatform
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


        if(storeDeviceList.value("stored-platforms") !== undefined){
            if(storeDeviceList.value("stored-platforms").hasOwnProperty("platforms")){
                const storedPlatforms = storeDeviceList.value("stored-platforms").platforms
                if(storedPlatforms.length > 0){
                    for(var x = 0; x < storedPlatforms.length; x++){
                        listModel.append({class_id: storedPlatforms[x].platform.class_id, opn: storedPlatforms[x].platform.opn, device_id: storedPlatforms[x].platform.device_id, firmware_version: storedPlatforms[x].platform.firmware_version, connected: false})
                    }
                    storeDeviceList.storedPlatforms = storeDeviceList.value("stored-platforms");
                } else {
                    listModel.append({class_id: "", opn: "" ,device_id: 0, firmware_version: "0.0.2", connected: false})
                }
            }
        } else {
            listModel.append({class_id: "", opn: "" ,device_id: 0, firmware_version: "0.0.2", connected: false})
        }
    }
    // Loads the new platform class_id, and stores the recently used platform or checks to see if it is a custom platform and stores it to the custom platforms
    function loadAndStorePlatform(platform, device_deviation ,firmwareVer, custom){
        const platforms = classModel
        for(var i = 0; i < platforms.count; i++){
            if(platform.class_id === platforms.get(i).platform.class_id && !custom){

                injectPlatform.list.push({
                                             "class_id": platform.class_id,
                                             "device_id": Constants.DEBUG_DEVICE_ID + device_deviation,
                                             "firmware_version": firmwareVer
                                         })
                let list = {
                    "list": injectPlatform.list,
                    "type":"connected_platforms"

                }

                PlatformSelection.parseConnectedPlatforms(JSON.stringify(list))
                var flag = false
                if(storeDeviceList.value("stored-platforms") !== undefined && storeDeviceList.storedPlatforms !== []) {
                    for( var j = 0; j < storeDeviceList.value("stored-platforms").platforms.length; j++){
                        const storedPlatforms = storeDeviceList.value("stored-platforms").platforms
                        if(storedPlatforms[j].platform.class_id === platform.class_id){
                            flag = true
                            break
                        }
                    }
                }
                if(!flag){
                    storeDeviceList.storedPlatforms.push({platform: {class_id: platform.class_id, opn: platform.opn, device_id: device_deviation ,firmware_version: firmwareVer, custom: custom } })
                    storeDeviceList.setValue("stored-platforms",{platforms: storeDeviceList.storedPlatforms})
                }
                break
            } else if(custom){
                injectPlatform.list.push({
                                             "class_id": platform.class_id,
                                             "device_id": Constants.DEBUG_DEVICE_ID + device_deviation,
                                             "firmware_version": firmwareVer
                                         })
                let list = {
                    "list": injectPlatform.list,
                    "type":"connected_platforms"

                }

                PlatformSelection.parseConnectedPlatforms(JSON.stringify(list))
                let flag = false
                if(storeDeviceList.value("stored-platforms") !== undefined && storeDeviceList.storedPlatforms !== []) {
                    for( var y = 0; y < storeDeviceList.value("stored-platforms").platforms.length; y++){
                        const storedPlatforms = storeDeviceList.value("stored-platforms").platforms
                        if(storedPlatforms[y].platform.class_id === platform.class_id){
                            flag = true
                            break
                        }
                    }
                }
                if(!flag){
                    storeDeviceList.storedPlatforms.push({platform: {class_id: platform.class_id, opn: platform.opn, device_id: device_deviation ,firmware_version: firmwareVer, custom: custom } })
                    storeDeviceList.setValue("stored-platforms",{platforms: storeDeviceList.storedPlatforms})
                }
                flag = false
                if(storeDeviceList.value("custom-platforms") !== undefined && storeDeviceList.customPlatforms !== []) {
                    for( let x = 0; x < storeDeviceList.value("custom-platforms").platforms.length; x++){
                        const storedPlatforms = storeDeviceList.value("custom-platforms").platforms
                        if(storedPlatforms[x].platform.class_id === platform.class_id){
                            flag = true
                            break
                        }
                    }
                }
                if(!flag){
                    storeDeviceList.customPlatforms.push({platform: {class_id: platform.class_id, opn: platform.opn, device_id: device_deviation ,firmware_version: firmwareVer, custom: custom } })
                    storeDeviceList.setValue("custom-platforms",{platforms: storeDeviceList.customPlatforms})
                }
                break
            } else {
                injectPlatform.list.push({
                                             "class_id": platform.class_id,
                                             "device_id": Constants.DEBUG_DEVICE_ID + device_deviation,
                                             "firmware_version": firmwareVer
                                         })
                let list = {
                    "list": injectPlatform.list,
                    "type":"connected_platforms"

                }
                PlatformSelection.parseConnectedPlatforms(JSON.stringify(list))
            }
        }
    }
    // Unloads and removes the Object containing the class_id in the InjectPlatform list
    function unloadAndRemovePlatform(classId){
        for(var i = 0; i < injectPlatform.list.length; i++){
            if(injectPlatform.list[i].class_id === classId){
                injectPlatform.list.splice(i,1)
                let list = {
                    "list": injectPlatform.list,
                    "type": "connected_platforms"
                }

                PlatformSelection.parseConnectedPlatforms(JSON.stringify(list))
                break
            }
        }
    }
    // Removes the index in both the stored-platforms and the listModel or remove the index in the listModel
    function deletePlatform(index){
        if(storeDeviceList.value("stored-platforms") !== undefined){
            if(storeDeviceList.value("stored-platforms").hasOwnProperty("platforms")){
                let storedPlatforms = storeDeviceList.value("stored-platforms").platforms
                listModel.remove(index)
                storedPlatforms.splice(index,1)
                injectPlatform.list.splice(index, 1)
                storeDeviceList.setValue("stored-platforms",{platforms: []})
                storeDeviceList.setValue("stored-platforms", {platforms: storedPlatforms})
            }
        } else {
            listModel.remove(index)
        }
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
    // OnEditingFinished for both the class_id.contentItem and the rowPlatform.version that will changeAndReplacePlatform the current Platform
    function changeAndReplacePlatform(platform, deviceId, firmwareVersion){
        for (var i = 0; i < injectPlatform.list.length; i++){
            if((deviceId + Constants.DEBUG_DEVICE_ID) === injectPlatform.list[i].device_id){
                injectPlatform.list.splice(i,1)
                let list = {
                    "list": injectPlatform.list,
                    "type":"connected_platforms"

                }
                PlatformSelection.parseConnectedPlatforms(JSON.stringify(list))
                loadAndStorePlatform(platform, deviceId, firmwareVersion, checkForCustomId(platform.class_id))
                break;
            }
        }
    }
}


