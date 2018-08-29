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
                anchors.bottom: schematicTabButton.top
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
                anchors.bottom: layoutTabButton.top
                anchors.right: layoutTabButton.right
                revisionCount: documentManager.layoutRevisionCount
            }
            onClicked: documentManager.clearLayoutRevisionCount()
        }

        TabButton {
            id:testReportTabButton
            text: "Test Report"

            CircleBadge {
                id: testReportBadge
                revisionCount: documentManager.testReportRevisionCount
                anchors.bottom: testReportTabButton.top
                anchors.right: testReportTabButton.right
            }
            onClicked: documentManager.clearTestReportRevisionCount()
        }

        TabButton { text: "System Content" }

        TabButton { text: "Efficiency Simulator" }

        TabButton {
            id:comingSoonTabButton
            text: "Coming Soon"

            CircleBadge {
                id: targetedBadge
                anchors.bottom: comingSoonTabButton.top
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

        PageSchematic { id: pageSchematic }
        PageLayout { id: pageLayout }
        PageTestReport { id: pageTestReport }
        PageSystemContent { id: pageSystemContent}
        EfficiencySimulator {
            width: view.width
            height: view.height - tabBar.height
        }
        PageComingSoon {id: pageComingSoonContent}
    }
}
