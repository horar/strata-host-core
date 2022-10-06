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
    id: qtFilterRulesDialog

    title: "Edit qtFilterRules"
    modal: true
    focus: true
    destroyOnClose: true
    closePolicy: Dialog.NoAutoClose
    headerIcon: "qrc:/sgimages/edit.svg"

    ListModel {
        id: sampleModel
        ListElement { imageName: "flower" }
        ListElement { imageName: "house" }
        ListElement { imageName: "water" }
    }

    Item {
        id: dialogContent
        implicitWidth: 400
        implicitHeight: 200

        ListView {
            id: sampleListView
            anchors.top: dialogContent.top
            width: dialogContent.width
            implicitHeight: 150
            model: sampleModel
            delegate: SGWidgets.SGTextField {
                width: parent.width
                text: imageName
            }
            spacing: 2
        }

        SGWidgets.SGButton {
            text: "Apply"
            anchors.top: sampleListView.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: qtFilterRulesDialog.accepted()
        }
    }
}
