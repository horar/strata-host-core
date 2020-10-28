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

Window {
    id: root
    width: 500
    height: 300
    maximumWidth: width
    maximumHeight: height
    minimumWidth: width
    minimumHeight: height
    title: "Control view development"

    property string qrcFilePath: ""
    property bool controlViewVisible: false

    property var stackContainer
    property var controlViewDevContainer

    Settings {
        category: "ControlViewDev"
        property alias qrcFilePath: root.qrcFilePath
    }

    ColumnLayout {
        anchors.centerIn: parent
        id: mainColumn
        spacing: 10

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter

            SGText {
                text: 'Recompile and reload RCC resources'
                fontSizeMultiplier: 1.6
                Layout.alignment: Qt.AlignLeft
                font {
                    family: Fonts.franklinGothicBook
                }
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
                            console.error("Error with QRC file path '" + root.qrcFilePath + "'")
                        }
                    }
                }
            }

            Button {
                id: recompileButton
                text: "Recompile QRC file"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onContainsMouseChanged: {
                        parent.highlighted = containsMouse
                    }

                    onClicked: {
                        sdsModel.resourceLoader.recompileControlViewQrc(root.qrcFilePath)
                        if (!root.controlViewVisible) {
                            stackContainer.currentIndex = stackContainer.count - 1
                            root.controlViewVisible = true
                        }
                    }
                }
            }

            Button {
                id: controlViewDisplayButton
                text: root.controlViewVisible ? "Disable Control View display" : "Enable Control View display"

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
                        root.controlViewVisible = !root.controlViewVisible
                    }
                }
            }
        }
    }

    Connections {
        target: sdsModel.resourceLoader

        onFinishedRecompiling: {
            if (filepath !== '') {
                loadDebugView(filepath)
            } else {
                let error_str = sdsModel.resourceLoader.getLastLoggedError()
                controlViewLoader.setSource(NavigationControl.screens.LOAD_ERROR,
                                            { "error_message": error_str });
            }
        }
    }

    function loadDebugView (compiledRccFile) {
        NavigationControl.removeView(root.controlViewDevContainer)

        let uniquePrefix = new Date().getTime().valueOf()
        uniquePrefix = "/" + uniquePrefix

        // Register debug control view object
        if (!sdsModel.resourceLoader.registerResource(compiledRccFile, uniquePrefix)) {
            console.error("Failed to register resource")
            return
        }

        let qml_control = "qrc:" + uniquePrefix + "/Control.qml"
        let obj = sdsModel.resourceLoader.createViewObject(qml_control, root.controlViewDevContainer);
        if (obj === null) {
            console.error("Could not load view.")
            let error_str = sdsModel.resourceLoader.getLastLoggedError()
            sdsModel.resourceLoader.createViewObject(NavigationControl.screens.LOAD_ERROR, root.controlViewDevContainer, {"error_message": error_str});
        }
    }
}
