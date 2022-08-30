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
import QtGraphicalEffects 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

GenericPopup {
    id: switchPopup

    property string sourceProperty
    property alias switchChecked: switchContainer.checked
    property alias label: label.text

    ColumnLayout {
        anchors.fill: parent

        Text {
            id: label
            text: "Please toggle the switch:"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        SGSwitch {
            id: switchContainer
            checkedLabel: "true"
            uncheckedLabel: "false"
            Layout.alignment: Qt.AlignHCenter
            grooveFillColor: Theme.palette.highlight
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: okButton
                text: "OK"
                onClicked: {
                    visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, sourceProperty, switchContainer.checked)
                    switchPopup.close()
                }
            }

            Button {
                text: "Cancel"
                onClicked: {
                    switchPopup.close()
                }
            }
        }
    }
}
