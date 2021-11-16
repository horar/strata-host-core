/*
 * Copyright (c) 2018-2021 onsemi.
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
import tech.strata.lcu 1.0

Item {
    id: lcuMain

    ConfigFileModel{
        id:configFileModel
    }

    Component.onCompleted: {
        configFileModel.reload()
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 5
        anchors.margins: 5

        SGWidgets.SGText {
            id: title
            text: "Configuration files"
        }

        Row {
            id: fileSelectorRow
            leftPadding: 10
            rightPadding: 10
            spacing: 5

            SGWidgets.SGComboBox {
                id: comboBox

                width: column.width - reloadButton.width - fileSelectorRow.leftPadding - fileSelectorRow.rightPadding - fileSelectorRow.spacing
                anchors.verticalCenter: reloadButton.verticalCenter
                model: configFileModel
                textRole: "fileName"
                onActivated: console.info("Selected INI file changed to: " + comboBox.currentText)
                enabled: count !== 0
                placeholderText: "no configuration files found"
                onCountChanged: {
                    if (count !==0 && currentIndex == -1) {
                        currentIndex = 0
                    }
                }
            }

            SGWidgets.SGButton {
                id: reloadButton
                width: height
                icon.source: "qrc:/sgimages/redo.svg"
                onClicked: {
                    configFileModel.reload()
                }
            }
        }
    }
}
