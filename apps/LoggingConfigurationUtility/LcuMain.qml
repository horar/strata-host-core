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

    property int outerSpacing: 10
    property int innerSpacing: 5

    ConfigFileModel {
        id:configFileModel
    }

    Component.onCompleted: {
        configFileModel.reload()
    }

    SGWidgets.SGText {
        id: title
        anchors {
            left: parent.left
            leftMargin: outerSpacing
        }
        text: "Configuration files"
    }

    SGWidgets.SGComboBox {
        id: comboBox
        anchors {
            top: title.bottom
            topMargin: innerSpacing
            left: title.left
            right: reloadButton.left
            rightMargin: innerSpacing
        }
        model: configFileModel
        textRole: "fileName"
        enabled: count !== 0
        placeholderText: "no configuration files found"
        onActivated: console.info("Selected INI file changed to: " + comboBox.currentText)
        popupHeight: parent.height - title.height - comboBox.height

        Connections {
            target: configFileModel
            onCountChanged: {
                if (comboBox.count == 0) {
                    comboBox.currentIndex = -1
                } else if (comboBox.count !== 0 && comboBox.currentIndex == -1) {
                    comboBox.currentIndex = 0
                } else {
                    comboBox.currentIndex = 0;
                }
            }
        }
    }

    SGWidgets.SGButton {
        id: reloadButton
        anchors {
            right: parent.right
            rightMargin: outerSpacing
            verticalCenter: comboBox.verticalCenter
        }
        width: height
        icon.source: "qrc:/sgimages/redo.svg"
        onClicked: configFileModel.reload()
    }
}
