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
import tech.strata.logconf 1.0

SGWidgets.SGDialog {
    id: qtFilterRulesDialog

    property string filterRulesString


    title: "Edit qtFilterRules"
    modal: true
    focus: true
    destroyOnClose: true
    closePolicy: Dialog.NoAutoClose
    headerIcon: "qrc:/sgimages/edit.svg"


    QtFilterRulesModel {
        id: filterRulesModel
    }

    Component.onCompleted: {
        filterRulesModel.createModel(filterRulesString)
    }

    Item {
        id: dialogContent
        implicitWidth: 250
        implicitHeight: 250

        ListView {
            id: filterRulesListView
            anchors.top: dialogContent.top
            width: dialogContent.width
            height: 150
            spacing: 2

            model: filterRulesModel
            delegate: SGWidgets.SGTextField {
                width: parent.width
                text: filterName

                onTextEdited: filterRulesModel.modifyList(index, text)
            }
        }

        SGWidgets.SGButton {
            text: "Apply"
            anchors.bottom: dialogContent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                filterRulesString = filterRulesModel.joinItems()
                qtFilterRulesDialog.accepted()
            }
        }
    }
}
