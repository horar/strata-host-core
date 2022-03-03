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
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: control
    anchors.fill: parent

    property alias model: repeater.model
    readonly property alias count: repeater.count
    property bool exclusive: true
    property int orientation: Qt.Horizontal

    /* Holds indexes of checked buttons in power of 2 format:
       for example:
       0       - no button checked
       1 = 2^0 - first button checked
       2 = 2^1 - second button checked
       4 = 2^2 - third button checked
       5 = 2^0 + 2^2 - first and third buttons checked
       6 = 2^1 + 2^2 - second and third buttons checked
       7 = 2^0 + 2^1 + 2^2 - first, second and third buttons checked
       8 = 2^3 - fourth button checked

       To check particular button, use isChecked(buttonIndex)
    */
    property int checkedIndices: 0

    signal clicked(int index)

    /* The easiest way to check particular button */
    function isChecked(index) {
        return checkedIndices & (1 << index)
    }

    GridLayout {
        id: strip
        anchors.fill: parent

        rows: orientation === Qt.Horizontal ? 1 : -1
        columns: orientation === Qt.Vertical ? 1 : -1
        columnSpacing: 1
        rowSpacing: 1

        Repeater {
            id: repeater

            delegate: Button {
                id: buttonDelegate
                Layout.fillWidth: true
                Layout.fillHeight: true

                text: modelData
                checkable: true
                checked: checkedIndices & powIndex

                Component.onCompleted: {
                    contentItem.color = Qt.binding(() => {return buttonStripContainer.textColor(buttonDelegate)})
                }

                property int powIndex: 1 << index
                property bool roundedLeft: orientation == Qt.Horizontal ? index === 0 : true
                property bool roundedRight: orientation == Qt.Horizontal ? index === repeater.count - 1 : true
                property bool roundedTop: orientation == Qt.Vertical ? index === 0 : true
                property bool roundedBottom :  orientation == Qt.Vertical ? index === repeater.count - 1 : true

                background:Item {
                    implicitHeight: 40
                    implicitWidth: 100
                    clip: true

                    Rectangle {
                        id:buttonBackground
                        anchors {
                            fill:parent
                            leftMargin: roundedLeft ? 0 : -radius
                            rightMargin: roundedRight ? 0 : -radius
                            topMargin: roundedTop ? 0 : -radius
                            bottomMargin: roundedBottom ? 0 : -radius
                        }

                        opacity: enabled ? 1 : 0.5
                        radius: 4

                        Component.onCompleted: {
                            color = Qt.binding(() => {return buttonStripContainer.color(buttonDelegate)})
                        }
                    }
                }

                onClicked: {
                    control.clicked(index)
                    if (control.exclusive) {
                        checkedIndices = 0
                        checkedIndices = powIndex
                    } else {
                        checkedIndices ^= powIndex
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onPressed:  {
                        mouse.accepted = false
                    }
                }
            }
        }
    }
}
