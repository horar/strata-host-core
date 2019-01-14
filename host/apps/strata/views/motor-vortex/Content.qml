import QtQuick 2.0
import QtQuick.Controls 2.0
import "."  //Import directory
import "qrc:/js/navigation_control.js" as NavigationControl
import tech.spyglass.DocumentManager 1.0
import tech.spyglass.Document 1.0
import "qrc:/include/Modules/"      // On Semi QML Modules
import "qrc:/views/efficiency-simulator/"
import "qrc:/views/motor-vortex/sgwidgets"

Rectangle {
    id: view
    anchors { fill: parent }

    Item {
        id: barContainer
        height: tabBar.height
        anchors {
            top: view.top
            right: view.right
            left: view.left
        }

        SGToolButton {
            id: downloadButton
            text: "Downloads"
            iconCharacter: "\ue80b"

            onClicked: {
                if (!downloadDrawer.visible) {
                    downloadDrawer.open()
                }
            }
        }

        Rectangle {
            id: div1
            anchors {
                left: downloadButton.right
            }
            width: 1
            height: tabBar.height
            color: "white"
        }

        TabBar {
            id: tabBar
            currentIndex: swipeView.currentIndex
            anchors {
                right: barContainer.right
                left: div1.right
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

            TabButton {
                id: ibdTabButton
                text: "Block Diagrams"
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
    }

    Item {
        id: contentContainer
        anchors {
            top: barContainer.bottom
            right: view.right
            left: view.left
            bottom: view.bottom
        }

        DownloadsDrawer {
            id: downloadDrawer
            height: contentContainer.height
            y: barContainer.height + view.parent.parent.statusBarHeight
        }

        SwipeView {
            id: swipeView
            anchors {
                fill: contentContainer
            }
            currentIndex: tabBar.currentIndex
            interactive: false
            PageSchematic { id: pageSchematic }
            PageLayout { id: pageLayout }
            PageInteractiveBlockDiagrams { id: pageInteractiveBlockDiagrams }
            EfficiencySimulator {
                width: view.width
                height: view.height - tabBar.height
            }
            //        PageSystemContent { id: pageSystemContent}
            PageComingSoon {id: pageComingSoonContent}
        }
    }
}
