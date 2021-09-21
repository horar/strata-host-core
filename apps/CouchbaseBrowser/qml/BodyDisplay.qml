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

import tech.strata.sgwidgets 1.0

import "Components"

Item {
    id: root

    property alias text: bodyView.text

    ScrollView {
        id: bodyViewContainer
        anchors.fill: parent
        clip: true

        TextArea {
            id: bodyView
            wrapMode: "Wrap"
            selectByMouse: true
            text: ""
            color: "#eeeeee"
            readOnly: true
            background: Rectangle {
                anchors.fill:parent

                color: "#393e46"
            }
        }
    }
    Item {
        width: 200
        height: 200
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        MouseArea {
            id: perimeter
            anchors.fill: parent

            hoverEnabled: true
            onEntered: fadeIn.start()
            onExited: fadeOut.start()
        }
        SGIcon {
            id: plusIcon
            width: 30
            height: 30
            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -20
                horizontalCenter: parent.horizontalCenter
            }

            fillMode: Image.PreserveAspectFit
            source: "Images/plus-icon.svg"
            opacity: 0.1
            iconColor: "limegreen"
            MouseArea {
                id: plusButton
                anchors.fill: parent

                onEntered: plusIcon.opacity = 0.8
                onExited: plusIcon.opacity = 1
                onClicked: {
                    if(bodyView.font.pixelSize < 40) {
                        bodyView.font.pixelSize += 5
                    }
                }
            }
        }
        SGIcon {
            id: minusIcon
            width: 30
            height: 30
            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: 30
                horizontalCenter: parent.horizontalCenter
            }

            fillMode: Image.PreserveAspectFit
            source: "Images/minus-icon.svg"
            opacity: 0.1
            iconColor: "darkred"
            MouseArea {
                id: minusButton
                anchors.fill: parent

                onEntered: minusIcon.opacity = 0.8
                onExited: minusIcon.opacity = 1
                onClicked: {
                    if(bodyView.font.pixelSize > 15 ){
                        bodyView.font.pixelSize -= 5
                    }
                }
            }
        }
    }
    NumberAnimation {
        id: fadeIn
        targets: [plusIcon, minusIcon]
        properties: "opacity"
        from: 0.1
        to: 1
        duration: 300
    }
    NumberAnimation {
        id: fadeOut
        targets: [plusIcon, minusIcon]
        properties: "opacity"
        from: 1
        to: 0.1
        duration: 300
    }
}
