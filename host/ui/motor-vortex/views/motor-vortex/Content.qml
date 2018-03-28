import QtQuick 2.0
import QtQuick.Controls 2.0
import "."  //Import directory
import "qrc:/js/navigation_control.js" as NavigationControl
import tech.spyglass.DocumentManager 1.0
import tech.spyglass.Document 1.0

Rectangle {
    id: view
    border.color: "black"
    border.width: 0
    anchors { fill: parent }

    SwipeView {
        id: swipeView
        anchors{ fill: parent }
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
            Rectangle {
                id: newSchematicBadge
                width: parent.width<parent.height?parent.width/1.9:parent.height/1.8
                height: width
                color: "red"
                radius: width*0.5
                anchors.bottom: parent.top
                anchors.right: parent.right
                anchors.bottomMargin: -20
                Text {
                    color: "white"
                    text: { return documentManager.revisionCount}
                    z:2
                    wrapMode: Text.WordWrap
                    anchors { fill: parent; centerIn: parent.Center }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                // Only show badge if rev is > 0
                visible: documentManager.revisionCount ? true : false
            }
            onClicked: documentManager.clearRevisionCount()
        }
        TabButton { text: "Layout"
            Rectangle {
                id: newLayoutBadge
                width: parent.width<parent.height?parent.width/1.9:parent.height/1.8
                height: width
                color: "red"
                radius: width*0.5
                anchors.bottom: parent.top
                anchors.right: parent.right
                anchors.bottomMargin: -20
                Text {
                    color: "white"
                    text: { return documentManager.revisionCount}
                    z:2
                    wrapMode: Text.WordWrap
                    anchors { fill: parent; centerIn: parent.Center }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                // Only show badge if rev is > 0
                visible: documentManager.revisionCount ? true : false
            }
            onClicked: documentManager.clearRevisionCount()
        }
        TabButton { text: "Test Report"
            Rectangle {
                id: newTestReportBadge
                width: parent.width<parent.height?parent.width/1.9:parent.height/1.8
                height: width
                color: "red"
                radius: width*0.5
                anchors.bottom: parent.top
                anchors.right: parent.right
                anchors.bottomMargin: -20
                Text {
                    color: "white"
                    text: { return documentManager.revisionCount}
                    z:2
                    wrapMode: Text.WordWrap
                    anchors { fill: parent; centerIn: parent.Center }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                // Only show badge if rev is > 0
                visible: documentManager.revisionCount ? true : false
            }
            onClicked: documentManager.clearRevisionCount()
        }
        TabButton { text: "System Content" }
        TabButton { text: "Coming Soon"
            Rectangle {
                id: newCommingSoonBadge
                width: parent.width<parent.height?parent.width/1.9:parent.height/1.8
                height: width
                color: "red"
                radius: width*0.5
                anchors.bottom: parent.top
                anchors.right: parent.right
                anchors.bottomMargin: -20
                Text {
                    color: "white"
                    text: { return documentManager.revisionCount}
                    z:2
                    wrapMode: Text.WordWrap
                    anchors { fill: parent; centerIn: parent.Center }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                // Only show badge if rev is > 0
                visible: documentManager.revisionCount ? true : false
            }
            onClicked: documentManager.clearRevisionCount()
        }
    }
    Image {
        id: flipButton
        source:"./images/icons/backIcon.svg"
        anchors { bottom: parent.bottom; right: parent.right }
        height: 40;width:40
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
