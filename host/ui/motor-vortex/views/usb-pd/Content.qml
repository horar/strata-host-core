import QtQuick 2.0
import QtQuick.Controls 2.0
import "."  //Import directory
import "qrc:/js/navigation_control.js" as NavigationControl
import tech.spyglass.DocumentManager 1.0
import tech.spyglass.Document 1.0
import "qrc:/include/Modules/"      // On Semi QML Modules

Rectangle {
    id: view
    border.color: "black"
    border.width: 0
    anchors { fill: parent }

    SwipeView {
        id: swipeView
        // Adjust Height for tabBar
        width: parent.width
        height: parent.height - tabBar.height
        currentIndex: tabBar.currentIndex
        PageSchematic { id: pageSchematic }
        PageLayout { id: pageLayout }
        PageTestReport { id: pageTestReport }
        PageSystemContent { id: pageSystemContent}
        PageComingSoon {id: pageComingSoonContent}
    }

    TabBar {
        id: tabBar

        width: parent.width - flipButton.width
        currentIndex: swipeView.currentIndex
        anchors { bottom: parent.bottom;}

        TabButton { text: "Schematic"
           CircleBadge {
               id: schematicBadge
               revisionCount: documentManager.schematicRevisionCount
           }
           onClicked: documentManager.clearSchematicRevisionCount()
        }
        TabButton { text: "Layout"
            CircleBadge {
                id: layoutBadge
                revisionCount: documentManager.layoutRevisionCount
            }
            onClicked: documentManager.clearLayoutRevisionCount()
        }
        TabButton { text: "Test Report"
            CircleBadge {
                id: testReportBadge
                revisionCount: documentManager.testReportRevisionCount
            }
            onClicked: documentManager.clearTestReportRevisionCount()
        }
        TabButton { text: "System Content" }
        TabButton { text: "Coming Soon"
            CircleBadge {
                id: targetedBadge
                revisionCount: documentManager.targetedRevisionCount
            }
            onClicked: documentManager.clearTargetedRevisionCount()
        }
    }
    Rectangle{
        height: 40;width:40
        anchors { bottom: view.bottom; right: view.right }
        color: "white";
        Image {
            id: flipButton
            source:"qrc:/views/usb-pd/images/icons/backIcon.svg"
            anchors { fill: parent }
            height: 40;width:40
        }
    }
    MouseArea {
        width: flipButton.width; height: flipButton.height
        anchors { bottom: parent.bottom; right: parent.right }
        visible: true
        onClicked: {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
}
