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
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import tech.strata.sgwidgets 1.0

GenericPopup {
    id: comboBoxPopup

    property string sourceProperty
    property alias model: comboBox.model
    property alias label: label.text

    ColumnLayout {
        anchors.fill: parent

        Text {
            id: label
            text: "Please select from the drop down:"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        SGComboBox {
            id: comboBox
            Layout.alignment: Qt.AlignHCenter
            model: ["Qt.Horizontal", "Qt.Vertical"]
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: okButton
                text: "OK"
                onClicked: {
                    visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, sourceProperty, comboBox.currentText)
                    comboBoxPopup.close()
                }
            }

            Button {
                text: "Cancel"
                onClicked: {
                    comboBoxPopup.close()
                }
            }
        }
    }
}
