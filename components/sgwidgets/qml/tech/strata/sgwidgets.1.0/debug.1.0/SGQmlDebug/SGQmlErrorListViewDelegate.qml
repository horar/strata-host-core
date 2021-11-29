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

Component {
    id: root
    
    Row {
        id: wrapper
        width: ListView.view.width
        spacing: 20
        
        Label {
            id: indexLabel
            text: qsTr("%1:").arg(index + 1)
        }
        
        TextInput {
            width: parent.width - indexLabel.contentWidth - 22
            Layout.fillWidth: true
            text: modelData
            selectByMouse: true
            readOnly: true
            wrapMode: TextInput.Wrap

            onFocusChanged: {
                if (focus) {
                    wrapper.ListView.view.currentIndex = index
                }
            }
        }
    }
}
