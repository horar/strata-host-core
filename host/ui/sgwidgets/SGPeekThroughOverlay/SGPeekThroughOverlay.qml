import QtQuick 2.9

Item {
     id: root
     width: parent.width
     height: parent.height
     opacity: .5
     visible: false

     signal clicked()

     MouseArea {
         anchors {
             fill: root
         }
         onClicked: root.clicked()
     }

     Rectangle {
         id: left
         color: "black"
         anchors {
             top: root.top
             left: root.left
             bottom: root.bottom
         }
         width: target.x
     }

     Rectangle {
         id: right
         color: "black"
         anchors {
             top: root.top
             right: root.right
             bottom: root.bottom
         }
         width: root.parent.width - target.width - left.width
     }

     Rectangle {
         id: top
         color: "black"
         anchors {
             top: root.top
             right: right.left
             left: left.right
         }
         height: target.y
     }

     Rectangle {
         id: bottom
         color: "black"
         anchors {
             bottom: root.bottom
             right: right.left
             left: left.right
         }
         height: root.parent.height - target.height - top.height
     }

     Image {
         id: topLeft
         anchors {
             left: left.right
             top: top.bottom
         }
         height: 30
         width: height
         source: "qrc:/images/corner-fade.png"
     }

     Image {
         id: topRight
         anchors {
             right: right.left
             top: top.bottom
         }
         height: 30
         width: height
         source: "qrc:/images/corner-fade.png"
         rotation: 90
     }

     Image {
         id: bottomRight
         anchors {
             right: right.left
             bottom: bottom.top
         }
         height: 30
         width: height
         source: "qrc:/images/corner-fade.png"
         rotation: 180
     }

     Image {
         id: bottomLeft
         anchors {
             left: left.right
             bottom: bottom.top
         }
         height: 30
         width: height
         source: "qrc:/images/corner-fade.png"
         rotation: 270
     }

     Image {
         id: leftFade
         anchors {
             top: topRight.bottom
             left: left.right
             bottom: bottomRight.top
         }
         width: 30
         source: "qrc:/images/side-fade.png"
     }

     Image {
         id: topFade
         anchors {
             top: top.bottom
             left: topLeft.right
             right: topRight.left
         }
         height: 30
         source: "qrc:/images/top-fade.png"
     }

     Image {
         id: rightFade
         anchors {
             top: topRight.bottom
             right: right.left
             bottom: bottomRight.top
         }
         width: 30
         source: "qrc:/images/side-fade.png"
         rotation: 180
     }

     Image {
         id: bottomFade
         anchors {
             bottom: bottom.top
             left: topLeft.right
             right: topRight.left
         }
         height: 30
         source: "qrc:/images/top-fade.png"
         rotation: 180
     }
 }
