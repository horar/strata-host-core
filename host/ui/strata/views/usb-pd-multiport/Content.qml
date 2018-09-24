import QtQuick 2.0
import QtQuick.Controls 2.0
import "."  //Import directory
import "qrc:/js/navigation_control.js" as NavigationControl
import tech.spyglass.DocumentManager 1.0
import tech.spyglass.Document 1.0
import "qrc:/include/Modules/"      // On Semi QML Modules
import "qrc:/views/efficiency-simulator/"

Rectangle {
    id: view
    anchors { fill: parent }

    TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex
        anchors {
            top: view.top
            right: view.right
            left: view.left
        }

        TabButton {
            id:schematicTabButton
            text: "Schematic"

            CircleBadge {
                id: schematicBadge
                anchors.top: schematicTabButton.top
                anchors.right: schematicTabButton.right
                revisionCount: documentManager.schematicRevisionCount
            }
            onClicked: documentManager.clearSchematicRevisionCount()
        }

        TabButton {
            id:layoutTabButton
            text: "Layout"

            CircleBadge {
                id: layoutBadge
                anchors.top: layoutTabButton.top
                anchors.right: layoutTabButton.right
                revisionCount: documentManager.layoutRevisionCount
            }
            onClicked: documentManager.clearLayoutRevisionCount()
        }

//        TabButton { text: "System Content" }

        TabButton {
            text: "Efficiency Simulator"
        }

        TabButton {
            id:comingSoonTabButton
            text: "Coming Soon"
            enabled: false

            CircleBadge {
                id: targetedBadge
                anchors.top: comingSoonTabButton.top
                anchors.right: comingSoonTabButton.right
                revisionCount: documentManager.targetedRevisionCount
            }
            onClicked: documentManager.clearTargetedRevisionCount()
        }
    }

    SwipeView {
        id: swipeView
        anchors {
            top: tabBar.bottom
            right: view.right
            left: view.left
            bottom: view.bottom
        }
        currentIndex: tabBar.currentIndex
        interactive: false
        Item { id: pageSchematic }
        Item { id: pageLayout }
        EfficiencySimulator {
            width: view.width
            height: view.height - tabBar.height
        }
//        PageSystemContent { id: pageSystemContent}
//        PageComingSoon {id: pageComingSoonContent}
    }
}
