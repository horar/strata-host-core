import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.3
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import "partial-views/"
import "js/core_platform_interface.js" as CorePlatformInterface

import tech.spyglass.sci 1.0
import fonts 1.0

Window {
    visible: true
    height: 600
    width: 900
    minimumWidth: 640
    minimumHeight: 480
    title: qsTr("Serial Console Interface")

    Item {
        id: root
        anchors {
            fill: parent
        }

        PlatformInterface {
            id: platformInterface
        }

        Component {
            id: newPlatformTab

            SGPlatformTab {}
        }

        Component {
            id: newPlatformContent

            SGPlatformContent {}
        }

        // This button adds tabs, but is commented out since tabs are automatically created on connection to platform
        // This can be used if the UX flow is changed
//        Rectangle {
//            id: addTabButton
//            color: "#666"
//            anchors {
//                top: root.top
//                left: root.left
//            }
//            height: tabBar.height
//            width: height

//            Text {
//                text: "\ue806"
//                font {
//                    family: Fonts.sgicons
//                    pixelSize: 20
//                }
//                color: "white"
//                anchors {
//                    centerIn: addTabButton
//                }
//            }

//            MouseArea {
//                anchors {
//                    fill: addTabButton
//                }
//                onClicked: CorePlatformInterface.addTabView()
//                hoverEnabled: true
//                onEntered: addTabButton.color = "#444"
//                onExited: addTabButton.color = "#666"
//            }
//        }

        TabBar {
            id: tabBar
            anchors {
                left: root.left //addTabButton.right
                top: root.top
                right: root.right
            }
            height: 35
            z: 10
            clip: true

            property int tabCount: 0

            background: Rectangle {
                color: "#666"
            }
        }

        StackLayout {
            id: platformContentContainer
            anchors {
                top: tabBar.bottom
                left: root.left
                right: root.right
                bottom: root.bottom
            }
            currentIndex: tabBar.currentIndex

            Component.onCompleted:
            {
                CorePlatformInterface.addTabView()  // Initialize interface with first tab /content
            }
        }
    }
}

