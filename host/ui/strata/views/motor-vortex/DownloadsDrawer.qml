import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import "qrc:/views/motor-vortex/sgwidgets"

Drawer {
    id: root
    implicitHeight: 600
    implicitWidth: 350
    dragMargin: 0
    edge: Qt.LeftEdge
    modal: false

    background: Rectangle {
        color: Qt.darker("#666")
    }

    contentItem: Item {
        id: content

        Item {
            id: downloadControlsContainer
            width: root.width - 120
            height: 500
            anchors {
                top: content.top
                topMargin: 60
                horizontalCenter: content.horizontalCenter
            }

            Column {
                id: contentColumn
                anchors {
                    horizontalCenter: downloadControlsContainer.horizontalCenter
                }

                Text {
                    id: title
                    text: "<b>Select files for download:</b>"
                    color: "white"
                    font {
                        pixelSize: 16
                    }
                }

                Item {
                    id: spacer1
                    height: 20
                    width: 1
                }

                Item {
                    id: radioButtonIndent
                    height: buttons.height
                    width: spacer3.width + buttons.width

                    Item {
                        id: spacer3
                        height: 1
                        width: 20
                    }

                    SGRadioButtonContainer {
                        id: buttons
                        anchors {
                            left: spacer3.right
                        }

                        textColor: "white"      // Default: "#000000"  (black)
                        radioColor: "white"     // Default: "#000000"  (black)
                        exclusive: false         // Default: true

                        radioGroup: Column {
                            spacing: 10

                            property alias datasheets : datasheets
                            property alias designPDFs: designPDFs
                            property alias cadFiles: cadFiles
                            property alias selectAll: selectAll

                            SGRadioButton {
                                id: selectAll
                                text: "Select All"
                                onCheckedChanged: {
                                    if (checked) {
                                        buttons.radioButtons.datasheets.checked = true
                                        buttons.radioButtons.designPDFs.checked = true
                                        buttons.radioButtons.cadFiles.checked = true
                                    } else if ( allChecked() ){
                                        buttons.radioButtons.datasheets.checked = false
                                        buttons.radioButtons.designPDFs.checked = false
                                        buttons.radioButtons.cadFiles.checked = false
                                    }
                                }
                            }

                            Item {
                                id: spacer2
                                height: 10
                                width: 1
                            }

                            SGRadioButton {
                                id: datasheets
                                text: "Datasheets"
                                onCheckedChanged: {
                                    if (!checked) {
                                        buttons.radioButtons.selectAll.checked = false
                                    } else if ( allChecked () ) {
                                        buttons.radioButtons.selectAll.checked = true
                                    }
                                }
                            }

                            SGRadioButton {
                                id: designPDFs
                                text: "Design PDFs"
                                onCheckedChanged: {
                                    if (!checked) {
                                        buttons.radioButtons.selectAll.checked = false
                                    } else if ( allChecked () ) {
                                        buttons.radioButtons.selectAll.checked = true
                                    }
                                }
                            }

                            SGRadioButton {
                                id: cadFiles
                                text: "CAD Files"
                                onCheckedChanged: {
                                    if (!checked) {
                                        buttons.radioButtons.selectAll.checked = false
                                    } else if ( allChecked () ) {
                                        buttons.radioButtons.selectAll.checked = true
                                    }
                                }
                            }

                            function allChecked() {
                                return buttons.radioButtons.datasheets.checked && buttons.radioButtons.designPDFs.checked && buttons.radioButtons.cadFiles.checked
                            }
                        }
                    }
                }

                Item {
                    id: spacer4
                    height: 20
                    width: 1
                }

                Button {
                    id: fileDialogButton
                    text: "Select Download Directory"
                    onClicked: fileDialog.visible = true
                }

                Item {
                    id: spacer5
                    height: 20
                    width: 1
                }

                TextEdit {
                    id: selectedDir
                    text: "No Directory Selected"
                    color: "white"
                    wrapMode: TextEdit.Wrap
                    width: downloadControlsContainer.width
                }

                Item {
                    id: spacer6
                    height: 20
                    width: 1
                }


            }

            Button {
                id: download
                enabled: (buttons.radioButtons.datasheets.checked || buttons.radioButtons.designPDFs.checked || buttons.radioButtons.cadFiles.checked) && fileDialog.fileUrl != ""
                anchors {
                    top: contentColumn.bottom
                    horizontalCenter: contentColumn.horizontalCenter
                }
                opacity: enabled ? 1 : .2

                contentItem: Text {
                    color: "white"
                    text: "Download"
                    opacity: 1
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                background: Rectangle {
                    color: "#33b13b"
                    implicitWidth: 100
                    implicitHeight: 40
                }

                onClicked: {
                    downloadActiveCoverup.visible = true
                    progressButton.text = "Cancel"
                    progressBarFake.start()
                }
            }
        }

        Rectangle {
            id: downloadActiveCoverup
            color: Qt.darker("#666")
            visible: false
            anchors {
                fill: downloadControlsContainer
            }

            MouseArea {
                id: mouseDisabler
                anchors {
                    fill: downloadActiveCoverup
                }
            }

            Rectangle {
                id: progressBarContainer
                height: 30
                border {
                    width: 1
                    color: "white"
                }
                color: "transparent"
                width: downloadActiveCoverup.width
                anchors {
                    centerIn: downloadActiveCoverup
                }

                Rectangle {
                    id: progressBar
                    color: "#33b13b"
                    height: progressBarContainer.height - 6
                    anchors {
                        verticalCenter: progressBarContainer.verticalCenter
                        left: progressBarContainer.left
                        leftMargin: 3
                    }
                    width: 1

                    PropertyAnimation {
                        id: progressBarFake
                        target: progressBar
                        property: "width"
                        from: 1
                        to: progressBarContainer.width - 6
                        duration: 2000
                        onStopped: {
                            progressButton.text = "Download Complete"
                        }
                    }
                }
            }

            Text {
                id: progressStatus
                text: "" + (100 * progressBar.width / (progressBarContainer.width - 6)).toFixed(0) + "% complete"
                color: "white"
                anchors {
                    bottom: progressBarContainer.top
                    right: progressBarContainer.right
                    bottomMargin: 3
                }
            }

            Button {
                id: progressButton
                anchors {
                    top: progressBarContainer.bottom
                    topMargin: 30
                    horizontalCenter: progressBarContainer.horizontalCenter
                }
                text: "Cancel"
                onClicked: downloadActiveCoverup.visible = false
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        folder: shortcuts.home
        selectFolder: true
        selectMultiple: false
        onAccepted: {
            selectedDir.text = "Files will be downloaded to:\n" + fileDialog.fileUrl
//            console.log("You chose: " + fileDialog.fileUrl)
        }
        onRejected: {
//            console.log("Canceled")
        }
    }

    Text {
        id: closer
        font {
            family: sgicons.name
            pixelSize: 18
        }
        color: "#888"
        text: "\ue805"
        anchors {
            top: root.contentItem.top
            topMargin: 20
            right: root.contentItem.right
            rightMargin: 20
        }

        MouseArea {
            anchors {
                fill: closer
            }
            onClicked: root.close()
        }
    }

    FontLoader {
        id: sgicons
        source: "sgwidgets/fonts/sgicons.ttf"
    }
}
