/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.fonts 1.0
import tech.strata.theme 1.0

RowLayout {
    id: root

    property alias text: textField.text
    property alias useCase: useCaseSensitive.checked

    spacing: 0

    SGControlViewIconButton {
        id: contentButton
        source: "qrc:/sgimages/zoom.svg"
        Layout.fillHeight: true
        Layout.preferredWidth: 30
        onClicked: {
            if(menu.opened){
                menu.close()
            } else {
                menu.open()
            }
        }
    }

    Rectangle {
        id: searchFilter
        Layout.fillHeight: true
        Layout.preferredWidth:  300
        border.color: "#444"
        border.width: 0.5

        SGTextField {
            id: textField
            font.pixelSize: 14
            anchors.fill: searchFilter
            leftPadding: 5
            contextMenuEnabled: true
            palette.highlight: Theme.palette.onsemiOrange
        }
    }

    Menu {
        id: menu
        width: root.width
        y: -menu.height

        MenuItem {
            SGCheckBox {
                id: useCaseSensitive
                text: "Case Sensitive"
                palette.highlight: Theme.palette.onsemiOrange
            }
        }
    }
}
