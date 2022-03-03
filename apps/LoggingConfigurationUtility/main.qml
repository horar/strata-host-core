/***************************************************************************
  Copyright (c) 2018-2022 onsemi.

   All rights reserved. This software and/or documentation is licensed by onsemi under
   limited terms and conditions. The terms and conditions pertaining to the software and/or
   documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
   Terms and Conditions of Sale, Section 8 Software”).
   ***************************************************************************/

import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import Qt.labs.platform 1.1 as QtLabsPlatform

SGWidgets.SGMainWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600

    visible: true
    title: qsTr("Logging Configuration Utility")

    QtLabsPlatform.MenuBar{
        QtLabsPlatform.Menu{
            title: "File"
            QtLabsPlatform.MenuItem{
            text: qsTr("&Exit")
            shortcut: "Ctrl+Q"
            onTriggered:
                root.close()
            }
        }
        QtLabsPlatform.Menu {
            title: "Help"
            QtLabsPlatform.MenuItem {
                text: qsTr("&About")
                onTriggered:  {
                    showAboutWindow()
                }
            }
        }

    }
    Rectangle {
        anchors.fill: parent
        color: "#eeeeee"
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/LcuAboutWindow.qml")
    }

}
