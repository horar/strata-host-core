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
import QtQuick.Window 2.12

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

ApplicationWindow {
    id: mainWnd
    visible: true
    width: 480
    height: 480
    title: qsTr("Main Window")

    Rectangle {
        id: container
        anchors {
            fill: parent
        }

        // This is an example column layout that disappears when all of its contents are popped out
        Rectangle {
            id: column1
            width: popout1.popped && popout2.popped ? 0 : container.width/2
            anchors {
                top: container.top
                bottom: container.bottom
                left: container.left
            }

            SGPopout {
                id: popout1
                title: "Popout 1"
                unpoppedHeight: container.height / 2  // NOTE THIS IS NOT WIDTH, IT IS UNPOPPEDWIDTH (to save the binding)
                unpoppedWidth: column1.width
            }

            SGPopout {
                id: popout2
                title: "Popout 2"
                unpoppedHeight: column1.height / 2
                unpoppedWidth: column1.width
                anchors {
                    top: popout1.bottom
                }
                overlaycolor: "lightblue"
            }
        }

        SGPopout {
            id: popout3
            title: "Popout 3"
            overlaycolor: "lightgreen"
            unpoppedWidth: parent.width / 2
            unpoppedHeight: parent.height
            content: SGGraphtimed {
                id: graph
                inputData: graphData.stream
            }
            anchors {
                left: column1.right
            }
        }
    }

    Timer {
        id: graphData
        property real stream
        property real count: 0
        interval: 100
        running: false
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin(count/500)*3+5;
        }
    }
}
