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

Button {
    id: root
    text: qsTr("Button")
    checkable: true
    enabled: masterEnabled
    hoverEnabled: masterHoverEnabled

    property alias buttonText: buttonText

    // Figures out which button this instance is
    Component.onCompleted: {
        if (root.parent.children.length === 1) {
            // single button style (hopefully this is never used)
            flatSide.width = 0;
            flatSide.height = 0;
        } else if (root.parent.children[root.parent.children.length-1] === root){
            // last button style
            flatSide.anchors.left = buttonStyle.left;
        } else if (root.parent.children[0] === root){
            // first button style
            flatSide.anchors.right = buttonStyle.right;
        } else {
            //middle buttons style
            flatSide.width = 0;
            flatSide.height = 0;
            buttonStyle.radius = 0;
        }
    }

    property real radius: masterRadius
    property color activeColor: masterActiveColor
    property color inactiveColor: masterInactiveColor
    property color textColor: masterTextColor
    property color textActiveColor: masterActiveTextColor
    property int index: 0

    signal indexUpdate(int index)

    background: Rectangle{
        id: buttonStyle
        color: root.hovered ? Qt.rgba( (activeColor.r + inactiveColor.r) / 2, (activeColor.g + inactiveColor.g) / 2, (activeColor.b + inactiveColor.b) / 2, 1) : root.checked ? activeColor : inactiveColor
        radius: root.radius
        implicitHeight: masterHeight
        implicitWidth: masterButtonImplicitWidth
        opacity: root.enabled ? 1.0 : 0.3
        layer.enabled: true

        Rectangle{
            id: flatSide
            height: buttonStyle.height
            width: buttonStyle.width/2
            color: buttonStyle.color
        }
    }

    contentItem: Text {
        id: buttonText
        text: root.text
        opacity: root.enabled ? 1.0 : 0.3
        color: root.checked ? root.textActiveColor : root.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    onCheckedChanged: {
        if (checked) {
            indexUpdate(root.index)
        }
    }
}
