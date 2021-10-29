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
    LcuModel { id: lcuModel }
    Column{
        SGWidgets.SGText{
            text: "Configuration Files"
            width: lcuMain.width
            height: lcuMain.height / 3
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        Row{
            SGWidgets.SGComboBox{
                id: comboBox
                width: (9./10.)* lcuMain.width
                Component.onCompleted: reloadButton.clicked()
                onActivated: lcuModel.configFileSelectionChanged(comboBox.currentText)
            }
            SGWidgets.SGButton{
                id: reloadButton
                width: (1./10.)* lcuMain.width
                height: comboBox.height
                icon.source: "qrc:/sgimages/redo.svg"
                onClicked: {
                    comboBox.model = lcuModel.getIniFiles()
                    if (comboBox.count == 0)
                        comboBox.enabled = false
                    else
                        comboBox.enabled = true
                }
            }
        }
    }
}
