import QtQuick 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import tech.strata.SGUtilsCpp 1.0

ColumnLayout {
    id: root

    spacing: 20

    property string outputFilePath: outputFileText.text
    property string inputFilePath: inputFileText.text

    AlertToast {
        id: alertToast
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        Layout.alignment: Qt.AlignTop

        spacing: 5

        Button {
            id: selectInputFileButton
            text: "Select Input File"
            Layout.preferredWidth: 200
            Layout.preferredHeight: 30


            Accessible.name: selectInputFileButton.text
            Accessible.role: Accessible.Button
            Accessible.onPressAction: {
                selectInputFileMouseArea.clicked()
            }


            MouseArea {
                id: selectInputFileMouseArea
                anchors.fill: parent
                hoverEnabled: true

                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                onClicked: {
                    inputFileDialog.open()
                }
            }
        }

        TextField {
            id: inputFileText
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            placeholderText: "Input File Location"
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        Layout.alignment: Qt.AlignTop
        spacing: 5

        Button {
            id: selectOutFolderButton
            text: "Select Output Folder"
            Layout.preferredWidth: 200
            Layout.preferredHeight: 30

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
                    outputFileDialog.open()
                }
            }
        }

        TextField {
            id: outputFileText
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            placeholderText: "Output Folder Location"
        }
    }

    Button {
        id: generateButton

        Layout.fillWidth: true
        Layout.preferredHeight: 30
        text: "Generate"

        enabled: root.inputFilePath !== "" && root.outputFilePath !== ""

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
                } else {
                    return generateButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
                }
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
                let result = generator.generate(inputFilePath, outputFilePath);
                if (!result) {
                    alertToast.text = "Generation Failed: " + generator.lastError
                    alertToast.textColor = "white"

                    alertToast.color = "#D10000"
                    alertToast.interval = 0
                } else if (generator.lastError.length > 0) {
                    alertToast.text = "Generation Succeeded, but with warnings: " + generator.lastError
                    alertToast.textColor = "black"
                    alertToast.color = "#DFDF43"
                    alertToast.interval = 0

                    debugMenuGenerator.generate(inputFilePath, outputFilePath);
                } else {
                    alertToast.textColor = "white"
                    alertToast.text = "Successfully generated PlatformInterface.qml"
                    alertToast.color = "green"
                    alertToast.interval = 4000

                    debugMenuGenerator.generate(inputFilePath, outputFilePath);
                }
                alertToast.show();
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
        selectMultiple: false
        selectExisting: true
        nameFilters: ["*.json"]

        onAccepted: {
            inputFileText.text = SGUtilsCpp.urlToLocalFile(fileUrl)
        }
    }
}
