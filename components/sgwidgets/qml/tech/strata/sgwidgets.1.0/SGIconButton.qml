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

Item {
    id: control

    implicitWidth: wrapper.width
    implicitHeight: wrapper.height

    property alias text: textItem.text
    property alias spacing: wrapper.spacing
    property color implicitIconColor: "black"
    property color alternativeIconColor: "white"
    property bool alternativeColorEnabled: false
    property bool showActiveFlag: false
    property bool showErrorFlag: false

    /* This is useful when you want to change text dynamically,
     * but dont want overall button width to be affected by text change.
     */
    property alias minimumWidthText: dummyText.text

    signal clicked()

    property alias iconColor: buttonItem.iconColor
    property alias iconSize: buttonItem.iconSize
    property alias icon: buttonItem.icon
    property alias hintText: buttonItem.hintText
    property alias highlightImplicitColor: buttonItem.implicitColor
    property alias hovered: buttonItem.hovered
    property alias backgroundOnlyOnHovered: buttonItem.backgroundOnlyOnHovered
    property alias iconMirror: buttonItem.iconMirror
    property alias padding: buttonItem.padding
    property alias checkable: buttonItem.checkable
    property alias checked: buttonItem.checked
    property alias pressed: buttonItem.pressed


    //cannot use TextMetrics as it provides wrong boundingRect.width for some font sizes (as of Qt 5.12.7)
    SGWidgets.SGText {
        id: dummyText
        visible: false
        font: textItem.font
    }

    Column {
        id: wrapper

        spacing: 4

        SGWidgets.SGButton {
            id: buttonItem
            anchors.horizontalCenter: parent.horizontalCenter

            padding: 2
            backgroundOnlyOnHovered: true
            scaleToFit: true
            iconColor: control.alternativeColorEnabled ? control.alternativeIconColor : control.implicitIconColor
            color: control.alternativeColorEnabled ? "#555555" : implicitColor
            onClicked: control.clicked()

            Rectangle {
                width: 16
                height: width
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }

                visible: showErrorFlag || showActiveFlag
                radius: 2
                color: {
                    if (showErrorFlag) {
                        return TangoTheme.palette.error
                    }

                    return TangoTheme.palette.chameleon2
                }


                SGWidgets.SGIcon {
                    width: parent.width - 4
                    height: width
                    anchors.centerIn: parent

                    iconColor: "white"
                    source: {
                        if (showErrorFlag) {
                            return "qrc:/sgimages/exclamation.svg"
                        }

                        return "qrc:/sgimages/circle.svg"
                    }
                }
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            height: textItem.contentHeight
            width: Math.max(dummyText.contentWidth, textItem.contentWidth)

            SGWidgets.SGText {
                id: textItem
                anchors.horizontalCenter: parent.horizontalCenter
                alternativeColorEnabled: control.alternativeColorEnabled
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
