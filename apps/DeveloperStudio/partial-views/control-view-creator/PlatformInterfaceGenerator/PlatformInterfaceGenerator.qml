import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0

import "../"

Item {
    id: root

    property alias root: root

    property bool unsavedChanges: false
    property string inputFilePath
    property string currentCvcProjectQrcUrl
    property string currentCvcProjectJsonUrl: editor.fileTreeModel.debugMenuSource
    property bool platformInterfaceGeneratorSeen
    property string apiVersion

    readonly property string jsonFileName: "platformInterface.json"

    readonly property var baseModel: ({
        "commands": [],
        "notifications": []
    })

    readonly property var templateCommand: ({
        "type": "cmd",
        "name": "",
        "valid": false,
        "payload": [],
        "editing": false
    })

    readonly property var templateNotification: ({
        "type": "value",
        "name": "",
        "valid": false,
        "payload": [],
        "editing": false
	})

    readonly property var templatePayload: ({
        "name": "", // The name of the property
        "type": sdsModel.platformInterfaceGenerator.TYPE_INT, // Type of the property, "array", "int", "string", etc.
        "indexSelected": 0,
        "valid": false,
        "array": [], // This is only filled if the type == "array"
        "object": [],
        "value": "0"
    })

    onVisibleChanged: {
        if (editor.fileTreeModel.url == "") {
            return
        }

        if (currentCvcProjectQrcUrl == editor.fileTreeModel.url) {
            return
        }

        currentCvcProjectQrcUrl = editor.fileTreeModel.url

        if (visible) {
            if (!platformInterfaceGeneratorSeen && currentCvcProjectJsonUrl != "") {
                alertToast.text = "Detected " + jsonFileName + " in the project. Select 'Import from Project' to load it."
                alertToast.textColor = "white"
                alertToast.color = "green"
                alertToast.interval = 8000
                alertToast.show()
            }
            platformInterfaceGeneratorSeen = true
        }
    }

    onCurrentCvcProjectQrcUrlChanged: {
        platformInterfaceGeneratorSeen = false
    }

    // All functions needed for PIG
    PIGFunctions {
        id: functions
    }

    // All deprecated functions needed for PIG
    PIGDeprecatedFunctions {
        id: deprecatedFunctions
    }

    ListModel {
        id: finishedModel

        Component.onCompleted: {
            let keys = Object.keys(baseModel)
            for (let i = 0; i < keys.length; i++) {
                let name = keys[i]
                let type = {
                    "name": name, // "commands" / "notifications"
                    "data": []
                }

                append(type)
            }
        }
    }

    ConfirmClosePopup {
        id: confirmOverwriteDialog
        acceptButtonText: "Yes"
        buttons: [...defaultButtons.slice(0, 1), ...defaultButtons.slice(1)]
        cancelButtonText: "Cancel"
        titleText: "PlatformInterface.qml already exists"
        popupText: "The output destination folder already contains 'PlatformInterface.qml'. Are you sure you want to overwrite this file?"

        onPopupClosed: {
            if (closeReason === cancelCloseReason) {
                return
            }

            if (closeReason === acceptCloseReason) {
                functions.generatePlatformInterface();
            }
        }
    }

    ConfirmClosePopup {
        id: confirmDeleteInProgress
        acceptButtonText: "Yes"
        buttons: [...defaultButtons.slice(0, 1), ...defaultButtons.slice(1)]
        cancelButtonText: "Cancel"
        titleText: "About to lose in progress work"
        popupText: "You currently have unsaved changes. If you continue, you will lose all progress made. Are you sure you want to continue?"

        onPopupClosed: {
            if (closeReason === cancelCloseReason) {
                return
            }

            if (closeReason === acceptCloseReason) {
                unsavedChanges = false
                functions.loadJsonFile(inputFilePath)
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        AlertToast {
            id: alertToast
        }

        Text {
            text: "Platform Interface Generator"
            Layout.alignment: Qt.AlignHCenter
            padding: 0
            font {
                bold: true
                pointSize: 24
            }
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            Layout.bottomMargin: 20
            color: "black"
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: 900
            Layout.preferredHeight: 60
            Layout.bottomMargin: 15
            Layout.alignment: Qt.AlignHCenter
            spacing: 50

            RowLayout {
                Button {
                    id: importJsonFileButton
                    Layout.preferredHeight: 30

                    icon {
                        source: "qrc:/sgimages/file-import.svg"
                        color: importJsonMouseArea.containsMouse ? Qt.darker("grey", 1.25) : "grey"
                        name: "Import JSON file"
                    }

                    text: "Import"
                    display: Button.TextBesideIcon
                    hoverEnabled: true

                    Accessible.name: "Open file dialog for importing a JSON file"
                    Accessible.role: Accessible.Button
                    Accessible.onPressAction: {
                        importJsonMouseArea.clicked()
                    }

                    MouseArea {
                        id: importJsonMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            alertToast.hide()
                            inputFileDialog.folder = functions.fileDialogFolder()
                            inputFileDialog.open()
                        }
                    }
                }

                Item {
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 200

                    Button {
                        id: importJsonFileFromProjectButton
                        enabled: currentCvcProjectJsonUrl != ""
                        anchors.fill: parent

                        icon {
                            source: "qrc:/sgimages/file-import.svg"
                            color: importFromProjectMouseArea.containsMouse ? Qt.darker("grey", 1.25) : "grey"
                            name: "Import JSON file from Project"
                        }

                        text: "Import from Project"
                        display: Button.TextBesideIcon
                        hoverEnabled: true

                        Accessible.name: "Import JSON file from Project"
                        Accessible.role: Accessible.Button
                        Accessible.onPressAction: {
                            importFromProjectMouseArea.clicked()
                        }
                    }

                    MouseArea {
                        id: importFromProjectMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: importJsonFileFromProjectButton.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (currentCvcProjectJsonUrl != "") {
                                functions.loadJsonFile(currentCvcProjectJsonUrl)
                            }
                        }

                        ToolTip {
                            text: "A project must be open and contain " + jsonFileName + " in its directory structure"
                            visible: !importJsonFileFromProjectButton.enabled && importFromProjectMouseArea.containsMouse
                        }
                    }
                }
            }

            ColumnLayout {
                RowLayout {
                    Layout.preferredWidth: outputFileText.width

                    Button {
                        id: selectOutFolderButton
                        text: "Select Output Directory"
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: (outputFileText.width - spacing)/2

                        Accessible.name: selectOutFolderButton.text
                        Accessible.role: Accessible.Button
                        Accessible.onPressAction: {
                            selectOutFolderMouseArea.clicked()
                        }

                        MouseArea {
                            id: selectOutFolderMouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                outputFileDialog.folder = functions.fileDialogFolder()
                                outputFileDialog.open()
                            }
                        }
                    }

                    Item {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: selectOutFolderButton.width

                        Button {
                            id: useProjectOutFolder
                            text: "Use Project Directory for Output"

                            anchors.fill: parent
                            enabled: currentCvcProjectQrcUrl != ""

                            Accessible.name: selectOutFolderButton.text
                            Accessible.role: Accessible.Button
                            Accessible.onPressAction: {
                                selectOutFolderMouseArea.clicked()
                            }
                        }

                        MouseArea {
                            id: useProjectOutFolderMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: useProjectOutFolder.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                outputFileText.text = functions.findProjectRootDir()
                            }

                            ToolTip {
                                text: "A project must be open"
                                visible: !useProjectOutFolder.enabled && useProjectOutFolderMouseArea.containsMouse
                            }
                        }
                    }
                }

                SGTextField {
                    id: outputFileText
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 500
                    placeholderText: "Output Folder Location"
                    contextMenuEnabled: true
                    readOnly: true
                }
            }
        }

        RowLayout {
            id: mainContainer

            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 20

            Repeater {
                model: finishedModel

                delegate: ColumnLayout {
                    id: commandColumn
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    property ListModel commandModel: model.data
                    property bool isCommand: index === 0

                    Text {
                        id: sectionTitle
                        Layout.fillWidth: true

                        text: model.name
                        font {
                            pixelSize: 16
                            capitalization: Font.Capitalize
                        }
                    }

                    /*****************************************
                    * This ListView corresponds to each command / notification
                    *****************************************/
                    ListView {
                        id: commandsListView
                        model: commandColumn.commandModel
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: contentHeight
                        Layout.preferredHeight: contentHeight
                        ScrollBar.vertical: ScrollBar {}

                        property var modelIndex: index

                        spacing: 10
                        clip: true

                        delegate: CommandNotificationDelegate {}
                    }

                    Button {
                        id: addCmdNotifButton
                        text: commandColumn.isCommand ? "Add command" : "Add notification"

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        Accessible.name: addCmdNotifButton.text
                        Accessible.role: Accessible.Button
                        Accessible.onPressAction: {
                            addCmdNotifMouseArea.clicked()
                        }

                        MouseArea {
                            id: addCmdNotifMouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (commandColumn.isCommand) {
                                    commandColumn.commandModel.append(templateCommand)
                                    commandsListView.contentY += 110
                                } else {
                                    commandColumn.commandModel.append(templateNotification)
                                }
                            }
                        }
                    }

                    Item {
                        // filler
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Unsaved changes detected"
            padding: 0
            visible: unsavedChanges
            color: "grey"
            font {
                bold: true
                pointSize: 10
            }
            horizontalAlignment: Text.AlignHCenter
        }

        Button {
            id: generateButton

            Layout.fillWidth: true
            Layout.maximumWidth: 600
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignHCenter

            text: "Generate"
            enabled: outputFileText.text !== ""

            Accessible.name: generateButton.text
            Accessible.role: Accessible.Button
            Accessible.onPressAction: {
                generateButtonMouseArea.clicked()
            }

            background: Rectangle {
                anchors.fill: parent
                color: {
                    if (!generateButton.enabled) {
                        return "lightgrey"
                    }
                    return generateButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
                }
            }

            contentItem: Text {
                text: "Generate"
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: generateButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true

                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                onClicked: {
                    let valid = functions.checkForAllValid()
                    if (!valid) {
                        alertToast.text = "Not all fields are valid! Make sure your command / notification names are unique."
                        alertToast.textColor = "white"
                        alertToast.color = "#D10000"
                        alertToast.interval = 0
                        alertToast.show()
                        return
                    }

                    // If the file already exists, prompt a popup confirming they want to overwrite
                    let fileName = SGUtilsCpp.joinFilePath(outputFileText.text, "PlatformInterface.qml")
                    if (SGUtilsCpp.isFile(fileName)) {
                        confirmOverwriteDialog.open()
                        return
                    }

                    functions.generatePlatformInterface()
                }
            }
        }
    }

    FileDialog {
        id: outputFileDialog
        selectFolder: true
        selectExisting: true
        selectMultiple: false

        onAccepted: {
            outputFileText.text = SGUtilsCpp.urlToLocalFile(fileUrl)
        }
    }

    FileDialog {
        id: inputFileDialog
        selectFolder: false
        selectExisting: true
        selectMultiple: false
        nameFilters: ["*.json"]

        onAccepted: {
            functions.loadJsonFile(fileUrl)
        }
    }
}
