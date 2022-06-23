/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

SGWidgets.SGDialog {
    id: corruptedFileDialog

    property alias corruptedParam: errorParamText.text
    property alias corruptedString: errorStringText.text
    property int horizSpacing: 20
    property int verticalSpacing: 15
    property color warningColor: "#E97D2E"
    property color buttonColor: palette.mid

    title: "Loading error"
    modal: true
    focus: true
    destroyOnClose: true
    closePolicy: Dialog.NoAutoClose
    headerBgColor: warningColor
    headerIcon: "qrc:/sgimages/exclamation-triangle.svg"

    Item {
        id: dialogContent
        implicitWidth: 400
        implicitHeight: column.height

        Column {
            id: column
            anchors.centerIn: parent
            spacing: verticalSpacing

            SGWidgets.SGText {
                horizontalAlignment: Qt.AlignCenter
                width: dialogContent.width
                wrapMode: Text.WordWrap
                text: "Selected INI file is corrupted."
            }

            SGWidgets.SGText {
                id: errorParamText
                horizontalAlignment: Qt.AlignCenter
                width: dialogContent.width
                wrapMode: Text.WordWrap
                text: corruptedParam
            }

            SGWidgets.SGText {
                id: errorStringText
                horizontalAlignment: Qt.AlignCenter
                width: dialogContent.width
                visible: corruptedString == "" ? false : true
                maximumLineCount: 7
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                color: warningColor
                font.bold: true
                font.pixelSize: 20
                text: corruptedString
            }

            SGWidgets.SGText {
                horizontalAlignment: Qt.AlignCenter
                width: dialogContent.width
                wrapMode: Text.WordWrap
                text: corruptedString == "" ? "An empty string is not a valid value for this parameter." : "which is an unrecognized value."
            }

            SGWidgets.SGText {
                horizontalAlignment: Qt.AlignCenter
                width: dialogContent.width
                wrapMode: Text.WordWrap
                text: "Do you want to set the parameter to default value or remove it?"
            }

            Row {
                id: row
                anchors.horizontalCenter: column.horizontalCenter
                spacing: verticalSpacing

                SGWidgets.SGButton {
                    text: "Set to default"
                    onClicked: corruptedFileDialog.accepted()
                    background: Rectangle {
                        anchors.fill: parent
                        radius: 5
                        color: parent.hovered ? warningColor : buttonColor
                    }
                }
                SGWidgets.SGButton {
                    text: "Remove parameter"
                    onClicked: corruptedFileDialog.rejected()
                    background: Rectangle {
                        anchors.fill: parent
                        radius: 5
                        color: parent.hovered ? warningColor : buttonColor
                    }
                }
            }
        }
    }
}
