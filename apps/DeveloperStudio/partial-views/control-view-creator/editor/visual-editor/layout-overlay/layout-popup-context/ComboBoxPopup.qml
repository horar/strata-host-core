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
import tech.strata.sglayout 1.0

GenericPopup {
    id: comboBoxPopup

    property string sourceProperty
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
            textRole: "name"
            model: comboBoxPopup.sourceProperty === "status" ? statusListModel : orientationListModel
        }

        ListModel {
            id: orientationListModel
            ListElement {
                name: "Qt.Horizontal"
                value: Qt.Horizontal
            }
            ListElement {
                name: "Qt.Vertical"
                value: Qt.Vertical
            }
        }

        ListModel {
            id: statusListModel
            ListElement {
                name: "LayoutSGStatusLight.Yellow"
                value: LayoutSGStatusLight.Yellow
            }
            ListElement {
                name: "LayoutSGStatusLight.Green"
                value: LayoutSGStatusLight.Green
            }
            ListElement {
                name: "LayoutSGStatusLight.Blue"
                value: LayoutSGStatusLight.Blue
            }
            ListElement {
                name: "LayoutSGStatusLight.Orange"
                value: LayoutSGStatusLight.Orange
            }
            ListElement {
                name: "LayoutSGStatusLight.Red"
                value: LayoutSGStatusLight.Red
            }
            ListElement {
                name: "LayoutSGStatusLight.Off"
                value: LayoutSGStatusLight.Off
            }
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

    function updateCurrentItem(currentItem) {
        for (let i = 0; i < comboBox.model.count; ++i) {
            if (comboBox.model.get(i).value === currentItem) {
                comboBox.currentIndex = i
                break
            }
        }
    }
}
