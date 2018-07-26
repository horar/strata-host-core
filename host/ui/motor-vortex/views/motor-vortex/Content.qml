import QtQuick 2.0
import QtQuick.Controls 2.0
import "."  //Import directory
import "qrc:/js/navigation_control.js" as NavigationControl
import tech.spyglass.DocumentManager 1.0
import tech.spyglass.Document 1.0
import "qrc:/include/Modules/"      // On Semi QML Modules

Rectangle {
    id: view
    anchors { fill: parent }

    TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
        }

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

    SwipeView {
        id: swipeView
        anchors {
            top: tabbar.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }
        currentIndex: tabBar.currentIndex
        PageSchematic { id: pageSchematic }
        PageLayout { id: pageLayout }
        PageTestReport { id: pageTestReport }
        PageSystemContent { id: pageSystemContent}
        PageComingSoon {id: pageComingSoonContent}
    }
}
