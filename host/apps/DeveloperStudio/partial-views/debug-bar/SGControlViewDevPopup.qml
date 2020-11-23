import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.1
import tech.strata.commoncpp 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/constants.js" as Constants

Window {
    id: root
    width: 500
    height: 350
    maximumWidth: width
    maximumHeight: height
    minimumWidth: width
    minimumHeight: height
    title: "Control view development"

    property string qrcFilePath: ""
    property bool controlViewVisible: controlViewDevContainer.visible
    property bool recompileRequested: false

    property var debugPlatform: ({
                                    "deviceId": Constants.NULL_DEVICE_ID,
                                    "classId": ""
                                 })

    onDebugPlatformChanged: {
        if (root.qrcFilePath.length > 0) {
            recompileResource()
        } else {
            console.error("Error with QRC file path")
        }
    }

    Settings {
        category: "ControlViewDev"
        property alias qrcFilePath: root.qrcFilePath
    }

    SGSortFilterProxyModel {
        id: connectedPlatforms
        sourceModel: []
        invokeCustomFilter: true

        function filterAcceptsRow(index) {
            return sourceModel.get(index).connected;
        }
    }

    ColumnLayout {
        id: mainColumn
        spacing: 10
        anchors.centerIn: parent
        width: parent.width - 30

        SGText {
            text: 'Recompile and reload RCC resources'
            fontSizeMultiplier: 1.6
            Layout.alignment: Qt.AlignLeft
            font {
                family: Fonts.franklinGothicBook
            }
        }

        Rectangle {
            // divider
            color: "#ddd"
            Layout.preferredHeight: 1
            Layout.fillWidth: true
        }


        SGText {
            text: "Current QRC Path:<br>" + root.qrcFilePath
            visible: root.qrcFilePath !== ""
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }

        Button {
            id: selectQrcFile
            text: "Select QRC file under development"

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onContainsMouseChanged: {
                    parent.highlighted = containsMouse
                }

                onClicked: {
                    console.info("Current QRC file path is '" + root.qrcFilePath + "'")
                    qrcFileDialog.open()
                }
            }

            FileDialog {
                id: qrcFileDialog
                title: "Select QRC file ('*.qrc')"
                folder: shortcuts.home
                selectExisting: true
                selectMultiple: false
                nameFilters: ["QRC file (*.qrc)"]

                onAccepted: {
                    let path = SGUtilsCpp.urlToLocalFile(qrcFileDialog.fileUrl);

                    // Set path to QRC file under development
                    if (path.length > 0) {
                        root.qrcFilePath = path
                        console.info("Set QRC file path to '" + root.qrcFilePath + "'")
                    } else {
                        console.error("Error with QRC file path")
                    }
                }
            }
        }



        SGComboBox {
            Layout.preferredHeight: 30
            Layout.preferredWidth: 350

            model: connectedPlatforms
            placeholderText: "Select a platform to connect to..."
            enabled: model.count > 0
            textRole: "verbose_name"

            onCurrentIndexChanged: {
                let platform = connectedPlatforms.get(currentIndex)
                debugPlatform = {
                    deviceId: platform.device_id,
                    classId: platform.class_id
                }
            }
        }

        Button {
            id: recompileButton
            text: "Recompile QRC file"
            enabled: root.qrcFilePath !== ""

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onContainsMouseChanged: {
                    parent.highlighted = containsMouse
                }

                onClicked: {
                    if (root.qrcFilePath.length > 0) {
                        recompileResource()
                    } else {
                        console.error("Error with QRC file path")
                    }
                }
            }
        }

        Button {
            id: controlViewDisplayButton
            text: root.controlViewVisible ? "Disable Control View display" : "Enable Control View display"
            enabled: root.qrcFilePath !== ""

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onContainsMouseChanged: {
                    parent.highlighted = containsMouse
                }

                onClicked: {
                    if (root.controlViewVisible) {
                        stackContainer.currentIndex = 0
                    } else {
                        stackContainer.currentIndex = stackContainer.count - 1
                    }
                }
            }
        }
    }

    Connections {
        target: sdsModel.resourceLoader

        onFinishedRecompiling: {
            if (recompileRequested) { // enforce that this popup requested the recompile
                recompileRequested = false
                if (filepath !== '') {
                    loadDebugView(filepath)
                } else {
                    let error_str = sdsModel.resourceLoader.getLastLoggedError()
                    controlViewDevContainer.setSource(NavigationControl.screens.LOAD_ERROR, {"error_message": error_str})
                }
            }
        }
    }

    Connections {
        target: mainWindow

        onInitialized: {
            connectedPlatforms.sourceModel = PlatformSelection.platformSelectorModel
        }
    }

    function recompileResource() {
        recompileRequested = true
        sdsModel.resourceLoader.recompileControlViewQrc(root.qrcFilePath)
        if (!root.controlViewVisible) {
            stackContainer.currentIndex = stackContainer.count - 1
        }
    }

    function loadDebugView (compiledRccFile) {
        controlViewDevContainer.setSource("")

        let uniquePrefix = new Date().getTime().valueOf()
        uniquePrefix = "/" + uniquePrefix

        // Register debug control view object
        if (!sdsModel.resourceLoader.registerResource(compiledRccFile, uniquePrefix)) {
            console.error("Failed to register resource")
            return
        }

        let qml_control = "qrc:" + uniquePrefix + "/Control.qml"

        Help.setClassId(debugPlatform.deviceId);
        NavigationControl.context.class_id = debugPlatform.classId
        NavigationControl.context.device_id = debugPlatform.deviceId

        controlViewDevContainer.setSource(qml_control, Object.assign({}, NavigationControl.context));
    }
}
