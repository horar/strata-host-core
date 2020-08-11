import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import Qt.labs.settings 1.1
import tech.strata.commoncpp 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

import "qrc:/js/platform_selection.js" as PlatformSelection

Window {
    id: root

    width: 600
    height: 400
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    title: "Local platform list selection"

    Column {
        id: mainColumn

        width: root.width
        y: root.height / 2 - height / 2
        spacing: 10
        padding: 10

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
            property: "height"
            to: 40
            duration: 100

            onFinished: {
                animationCloseTimer.start()
            }
        }

        NumberAnimation{
            id: hideAlertAnimation
            target: alertRect
            property: "height"
            to: 0
            duration: 100
            onStarted: alertText.text = ""
        }

        Row {
            id: loadRow

            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

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

            anchors.horizontalCenter: parent.horizontalCenter
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
            anchors.horizontalCenter: parent.horizontalCenter
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

        Settings {
            id: localPlatformSettings
            category: "LocalPlatformList"
        }

        function removeLocalPlatformList() {
            PlatformSelection.setLocalPlatformList([])
            localPlatformSettings.setValue("path", "")
        }
    }
}
