/***************************************************************************
  Copyright (c) 2018-2021 onsemi.

   All rights reserved. This software and/or documentation is licensed by onsemi under
   limited terms and conditions. The terms and conditions pertaining to the software and/or
   documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
   Terms and Conditions of Sale, Section 8 Software”).
   ***************************************************************************/

import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import tech.strata.lcu 1.0

Item {
    id: lcuMain

    LcuModel{
        id:lcuModel
    }

    Component.onCompleted: {
        reloadButton.clicked()
    }
    Column{
        SGWidgets.SGText{
            id: title
            text: "Configuration files"           
            width: lcuMain.width //look if i need to set w&h
            height: 0.08 * lcuMain.height
            //fontSizeMultiplier:
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        Row{
            SGWidgets.SGComboBox{
                id: comboBox
                width: lcuMain.width - reloadButton.width
                height: 0.08 * lcuMain.height
                model: lcuModel
                onActivated: console.info("Selected INI file changed to: " + comboBox.currentText)
                //enabled: model.rowCount =! 0
            }
            SGWidgets.SGButton{
                id: reloadButton
                width: comboBox.height
                height: comboBox.height
                icon.source: "qrc:/sgimages/redo.svg"
                onClicked: {
                    //reload list of ini files
                }    
            }
        }
    }
}
