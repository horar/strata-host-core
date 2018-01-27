import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
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
                id: newSchematicDocuments
                width: parent.width<parent.height?parent.width/1.9:parent.height/1.8
                height: width
                color: "red"
                radius: width*0.5
                anchors.bottom: parent.top
                anchors.right: parent.right
                anchors.bottomMargin: -20
                Text {
                    color: "white"
                    text: "2"
                    z:2
                    wrapMode: Text.WordWrap
                    anchors { fill: parent; centerIn: parent.Center }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            onClicked: newSchematicDocuments.visible = false
        }
        TabButton { text: "Layout"
            Rectangle {
                id: newLayoutDocuments
                width: parent.width<parent.height?parent.width/1.9:parent.height/1.8
                height: width
                color: "red"
                radius: width*0.5
                anchors.bottom: parent.top
                anchors.right: parent.right
                anchors.bottomMargin: -20
                Text {
                    color: "white"
                    text: "3"
                    z:2
                    wrapMode: Text.WordWrap
                    anchors { fill: parent; centerIn: parent.Center }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            onClicked: newLayoutDocuments.visible = false
        }
        TabButton { text: "Test Report"
            Rectangle {
                id: newTestDocuments
                width: parent.width<parent.height?parent.width/1.9:parent.height/1.8
                height: width
                color: "red"
                radius: width*0.5
                anchors.bottom: parent.top
                anchors.right: parent.right
                anchors.bottomMargin: -20
                Text {
                    color: "white"
                    text: "5"
                    z:2
                    wrapMode: Text.WordWrap
                    anchors { fill: parent; centerIn: parent.Center }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            onClicked: newTestDocuments.visible = false
        }
        TabButton { text: "System Content" }
        TabButton { text: "Coming Soon"
            Rectangle {
                id: newComingSoonDocuments
                width: parent.width<parent.height?parent.width/1.9:parent.height/1.8
                height: width
                color: "red"
                radius: width*0.5
                anchors.bottom: parent.top
                anchors.right: parent.right
                anchors.bottomMargin: -20
                Text {
                    color: "white"
                    text: "2"
                    z:2
                    wrapMode: Text.WordWrap
                    anchors { fill: parent; centerIn: parent.Center }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            onClicked: newComingSoonDocuments.visible = false
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
        onClicked: flipable.flipped = !flipable.flipped
    }
}
