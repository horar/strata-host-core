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
        PageBlockDiagram { id: pageBlockDiagram }
        PageSchematic { id: pageSchematic }
        PageLayout { id: pageLayout }
        PageTestReport { id: pageTestReport }
        PageSystemContent {id: pageSystemContent}
        PageComingSoon {id: pageComingSoonContent}
    }
    
    TabBar {
        id: tabBar
        width: parent.width - flipButton.width
        currentIndex: swipeView.currentIndex
        anchors { bottom: parent.bottom;}
        TabButton { text: "Block Diagram" }
        TabButton { text: "Schematic" }
        TabButton { text: "Layout" }
        TabButton { text: "Test Report" }
        TabButton { text: "System Content" }
        TabButton { text: "Coming Soon" }
    }
    
    Image {
        id: flipButton
        source:"backIcon.svg"
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
