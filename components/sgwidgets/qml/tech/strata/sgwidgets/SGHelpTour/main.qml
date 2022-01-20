/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import "qrc:/help_layout_manager.js" as Help

/*
See help_layout_manager for API that is used in this file.
*/

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Window {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("")
    property variant clickPos: "1,1" // @disable-check M311 // Ignore 'use string' (M311) QtCreator warning

    Component.onCompleted: {
        Help.registerWindow(root)
        Help.registerTarget(myBox, "this is the first box", 0, "basicViewHelp")
        Help.registerTarget(myBox2, "this is the second box", 1, "basicViewHelp")
    }

    onClosing: { // @disable-check M16  // Ignore "invalid property name" warning
        Help.destroyHelp()  // Necessary to remove dynamically created help views. If inside of a dynamically created object, use component.ondestruction instead
    }

    Rectangle {
        id: originalContainer
        color: "tomato"
        anchors {
            centerIn: parent
        }
        opacity: 0.75
        width: 210
        height: width
    }

    Button {
        id: showOverlay
        text: "Start Help Tour"
        onClicked: {
            Help.startHelpTour("basicViewHelp")
        }
        anchors {
            top: originalContainer.bottom
            horizontalCenter: originalContainer.horizontalCenter
        }
    }

    Rectangle {
        id: myBox
        color: "tomato"
        x: root.width/2 - myBox.width/2
        y: root.height/2 - myBox.height/2
        width: 200
        height: width

        MouseArea {
            anchors {
                fill: parent
            }
            onPressed: {
                root.clickPos = Qt.point(mouse.x,mouse.y)
            }
            onPositionChanged: {
                var delta = Qt.point(mouse.x-root.clickPos.x, mouse.y-root.clickPos.y)
                myBox.x += delta.x;
                myBox.y += delta.y;
            }
        }

        Text {
            id: text
            anchors {
                centerIn: myBox
            }
            text: "Drag Me Around"
        }
    }

    Rectangle {
        id: myBox2
        color: "cyan"
        x: parent.width/6
        y: x
        width: 100
        height: width

        Text {
            id: box2text
            text: "Secondary Target Box"
            anchors {
                centerIn: parent
            }
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
