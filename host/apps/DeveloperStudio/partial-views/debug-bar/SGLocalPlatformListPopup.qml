import QtQuick 2.12
import QtQml 2.12
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
        if (visible) {
            initialModelLoad()
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
                        removeLocalPlatformList()
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
                        removeLocalPlatformList()
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
                            manipulateFlags(model[index],modelData)
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
                        Layout.preferredWidth: 80
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
                    model: platformModel
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    Layout.maximumHeight: 300
                    clip: true
                    spacing: 5

                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }

                    delegate: RowLayout {
                        id: platformRow
                        Layout.fillWidth: true

                        property var class_id: model.class_id
                        property var opn: model.opn
                        property int device_id: model.device_id
                        property string firmware_version: model.firmware_version
                        property bool connected: model.connected


                        onDevice_idChanged: {
                            if(platformModel.initialized){
                                deviceIdComboBox.currentIndex = device_id
                            }
                        }

                        function setDevice_id(device_id) {
                            model.device_id = device_id
                        }

                        function setFirmware_version(firmware_version) {
                            model.firmware_version = firmware_version
                        }

                        function setClass_id(class_id) {
                            model.class_id = class_id
                        }

                        function setOpn(opn) {
                            model.opn = opn
                        }

                        Rectangle {
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: Layout.preferredHeight
                            color: "red"

                            SGIcon {
                                source:"qrc:/sgimages/times.svg"
                                anchors.centerIn: parent
                                width: 25
                                height: width
                                iconColor: "white"
                            }

                            MouseArea {
                                id: closeArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    model.connected = false
                                    updateConnectedPlatforms()
                                    platformModel.remove(index)
                                    storeState()
                                }
                            }
                        }


                        RowLayout {
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 310
                            Layout.fillWidth: false
                            spacing: 0

                            SGTextField {
                                id: classIDField
                                placeholderText: "Class Id..."
                                text: platformRow.class_id
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                enabled: !platformRow.connected

                                background: Rectangle {
                                    color: "transparent"
                                    border.color: parent.enabled ? "gray" : "lightGray"
                                    border.width: 0.5
                                    anchors.fill: parent
                                }

                                property bool textChanged: false

                                onTextChanged: {
                                    textChanged = true
                                }

                                onEditingFinished: {
                                    if (textChanged && platformRow.class_id !== text && text !== ""){
                                        setClassId()
                                    }
                                    textChanged = false
                                }

                                function setClassId () {
                                    let opn = findOPN(text)
                                    platformRow.setClass_id(text)
                                    platformRow.setOpn(opn)
                                    addToRecentPlatforms(text, opn)
                                    storeState()
                                    if (platformRow.connected){
                                        updateConnectedPlatforms()
                                    }
                                }
                            }

                            Rectangle {
                                Layout.preferredHeight: 40
                                Layout.preferredWidth: 40
                                border.color: "lightGrey"
                                border.width: 1
                                // Currently, changing the class_id while still connected is an undefined behavior in platform_selection.js
                                enabled: !platformRow.connected

                                SGIcon {
                                    width: 25
                                    height: 25
                                    anchors.centerIn: parent
                                    source: "qrc:/sgimages/chevron-down.svg"
                                    iconColor: "lightGrey"
                                    enabled: parent.enabled
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    enabled: parent.enabled

                                    onClicked: {
                                        forceActiveFocus()
                                        popUp.open()
                                    }
                                }
                            }

                            Popup {
                                id: popUp
                                width: parent.width
                                height: 485
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
                                            text: "Platform Selector List"
                                            enabled: popUpView.model !== PlatformSelection.platformSelectorModel

                                            onClicked: {
                                                popUpView.model = PlatformSelection.platformSelectorModel
                                            }
                                        }

                                        SGButton {
                                            Layout.preferredHeight: 40
                                            Layout.preferredWidth: 140
                                            text: "Recent Platforms"
                                            enabled: popUpView.model !== recentPlatformsModel
                                            onClicked: {
                                                popUpView.model = recentPlatformsModel
                                            }
                                        }
                                    }

                                    Rectangle {
                                        // divider
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
                                        model: PlatformSelection.platformSelectorModel
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
                                                text: model.opn
                                                leftPadding: 5
                                            }

                                            SGText {
                                                id: classText
                                                color: delegateArea.containsMouse ? "#888" : "#333"
                                                anchors.left: parent.left
                                                anchors.top: opnText.bottom
                                                text: model.class_id
                                                leftPadding: 10
                                            }

                                            MouseArea {
                                                id: delegateArea
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true

                                                onClicked: {
                                                    classIDField.text = model.class_id
                                                    classIDField.setClassId()
                                                    popUp.close()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        SGTextField {
                            id: firmwareVersion
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 80
                            placeholderText: "Firmware version #.#.#"
                            text: platformRow.firmware_version

                            property bool textChanged: false

                            onTextChanged: {
                                textChanged = true
                            }

                            onEditingFinished: {
                                if (textChanged && platformRow.firmware_version !== text && text !== ""){
                                    platformRow.setFirmware_version(text)
                                    if (platformRow.connected){
                                        updateConnectedPlatforms()
                                    }
                                }
                                textChanged = false
                            }
                        }

                        SGComboBox {
                            id: deviceIdComboBox
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 150
                            model: deviceModel
                            enabled: !platformRow.connected
                            textRole: "name"
                            popupHeight: 485

                            onCurrentIndexChanged: {
                                const newDevice = model.get(currentIndex)
                                if(newDevice){
                                    displayText = newDevice.name
                                    platformRow.setDevice_id(newDevice.device_id)
                                }
                            }
                        }

                        Switch {
                            id: connectSwitch
                            checked: model.connected
                            enabled: model.connected || (platformRow.class_id !== "" && platformRow.device_id !== -1 && platformRow.firmware_version !== "")

                            onCheckedChanged: {
                                model.connected = checked
                                updateConnectedPlatforms()
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
                    enabled: platformModel.count < platformModel.max_platforms

                    onClicked: {
                        if(enabled){
                            platformModel.append({class_id: "", opn: "", device_id: platformModel.count, firmware_version: "0.0.0", connected: false})
                        }
                    }
                }
            }
        }
    }

    Settings {
        id: localPlatformSettings
        category: "LocalPlatformList"
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

    ListModel {
        id: platformModel

        property bool initialized: false
        property int max_platforms: 10
    }

    ListModel {
        id: recentPlatformsModel
    }

    // The model for the deviceIdComboBox
    ListModel {
        id: deviceModel
    }

    // Loads a device model, and prepends the classModel with any saved custom platforms
    function initialModelLoad() {
        if (platformModel.initialized === false) {
            for (var j = 0; j < 10; j++) {
                deviceModel.append({name: `device_id ${j}`, device_id: j})
            }

            readState()

            if (platformModel.count === 0) {
                platformModel.append({class_id: "", opn: "---", device_id: 0, firmware_version: "0.0.0", connected: false})
            }

            platformModel.initialized = true
        }
    }

    // Loads the new platform class_id, and stores the recently used platform or checks to see if it is a custom platform and stores it to the custom platforms
    function updateConnectedPlatforms() {

        let injectList = {
            "list": [],
            "type": "connected_platforms"
        }

        for (var i = 0; i < platformModel.count; i++) {
            const updatedPlatform = platformModel.get(i)
            if (updatedPlatform.connected) {
                injectList.list.push({
                                         "class_id": updatedPlatform.class_id,
                                         "device_id": updatedPlatform.device_id + Constants.DEBUG_DEVICE_ID,
                                         "firmware_version": updatedPlatform.firmware_version
                                     })
            }
        }

        PlatformSelection.parseConnectedPlatforms(JSON.stringify(injectList))
    }

    // Finds OPN for a custom class_id
    function findOPN(classId){
        for (var i = 0; i < PlatformSelection.platformSelectorModel.count; i++) {
            if (classId === PlatformSelection.platformSelectorModel.get(i).class_id) {
                return PlatformSelection.platformSelectorModel.get(i).opn
            }
        }
        return "---"
    }

    // Check if class_id is in recent list, if not, append
    function addToRecentPlatforms(class_id, opn) {
        for (var j = 0; j < recentPlatformsModel.count; j++) {
            if (recentPlatformsModel.get(j).class_id === class_id) {
                if (recentPlatformsModel.get(j).opn !== opn && opn !== "---") {
                    // update opn if not matching
                    recentPlatformsModel.get(j).opn = opn
                }
                return
            }
        }
        recentPlatformsModel.append({class_id: class_id, opn: opn})
    }

    // Read last state from disk
    function readState() {
        if (localPlatformSettings.value("recent-platforms") !== undefined) {
            const storedPlatforms = JSON.parse(localPlatformSettings.value("recent-platforms"))
            for (var x = 0; x < storedPlatforms.length; x++) {
                recentPlatformsModel.append({class_id: storedPlatforms[x].class_id, opn: storedPlatforms[x].opn})
            }
        }

        if (localPlatformSettings.value("last-state") !== undefined) {
            const lastPlatforms = JSON.parse(localPlatformSettings.value("last-state"))
            for (var i = 0; i < lastPlatforms.length; i++) {
                platformModel.append({class_id: lastPlatforms[i].class_id, opn: lastPlatforms[i].opn, device_id: i, firmware_version: "0.0.0", connected: false})
            }
        }
    }

    // Save recently used platforms to disk
    function storeState() {
        let recentPlatforms = []
        for (var i = 0; i < recentPlatformsModel.count; i++){
            let recentPlatform = recentPlatformsModel.get(i)
            recentPlatforms.push({class_id: recentPlatform.class_id, opn: recentPlatform.opn})
        }
        localPlatformSettings.setValue("recent-platforms", JSON.stringify(recentPlatforms))

        let platformState = []
        for (var j = 0; j < platformModel.count; j++){
            let platform = platformModel.get(j)
            if (platform.class_id !== "") {
                platformState.push({class_id: platform.class_id, opn: platform.opn})
            }
        }
        localPlatformSettings.setValue("last-state", JSON.stringify(platformState))
    }
}
