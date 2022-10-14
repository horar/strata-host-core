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
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

SGWidgets.SGDialog {
    id: createFolderDialog

    property string filePath
    property int innerSpacing: 10

    title: "Create new folder?"
    modal: true
    focus: true
    destroyOnClose: true
    closePolicy: Dialog.NoAutoClose
    headerBgColor: Theme.palette.warning
    headerIcon: "qrc:/sgimages/folder-plus.svg"

    ColumnLayout {
        Layout.alignment: Qt.AlignCenter
        spacing: innerSpacing

        SGWidgets.SGText {
            id: pathText
            Layout.maximumWidth: 400

            text: (filePath.length <= 300) ? "Path <b>" + filePath + "</b> does not exist." : "Path <b>..." + filePath.substring(filePath.length-300, filePath.length-1) + "</b> does not exist."
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        SGWidgets.SGText {
            id: questionText
            text: "Do you want to create this directory?"
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: innerSpacing

            SGWidgets.SGButton {
                text: "Yes"

                onClicked: createFolderDialog.accepted()
            }

            SGWidgets.SGButton {
                text: "No"

                onClicked: createFolderDialog.rejected()
            }
        }
    }
}
