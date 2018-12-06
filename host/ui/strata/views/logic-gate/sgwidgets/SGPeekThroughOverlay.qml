import QtQuick 2.9

Item {
     id: root
     width: fill.width
     height: fill.height
     opacity: .5
     visible: false

     signal clicked()

     property var remappedTarget

     Component.onCompleted: remappedTarget = target.mapToItem(fill, 0, 0)

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
         width: remappedTarget.x
     }

     Rectangle {
         id: right
         color: "black"
         anchors {
             top: root.top
             right: root.right
             bottom: root.bottom
         }
         width: fill.width - target.width - left.width
     }

     Rectangle {
         id: top
         color: "black"
         anchors {
             top: root.top
             right: right.left
             left: left.right
         }
         height: remappedTarget.y
     }

     Rectangle {
         id: bottom
         color: "black"
         anchors {
             bottom: root.bottom
             right: right.left
             left: left.right
         }
         height: fill.height - target.height - top.height
     }

     Image {
         id: topLeft
         anchors {
             left: left.right
             top: top.bottom
         }
         height: Math.min(30, target.height/2)
         width: Math.min(30, target.width/2)
         source: "images/corner-fade.png"
     }

     Image {
         id: topRight
         anchors {
             right: right.left
             top: top.bottom
         }
         height: bottomRight.width
         width: bottomRight.height
         source: "images/corner-fade.png"
         transform: Rotation { origin.x: topRight.width/2; origin.y: topRight.width/2; angle: 90}
     }

     Image {
         id: bottomRight
         anchors {
             right: right.left
             bottom: bottom.top
         }
         height: Math.min(30, target.height/2)
         width: Math.min(30, target.width/2)
         source: "images/corner-fade.png"
         rotation: 180
     }

     Image {
         id: bottomLeft
         anchors {
             left: left.right
             bottom: bottom.top
         }
         height: topLeft.width
         width: topLeft.height
         source: "images/corner-fade.png"
         transform: Rotation { origin.x: bottomLeft.height/2; origin.y: bottomLeft.height/2; angle: -90}

     }

     Image {
         id: leftFade
         anchors {
             top: topLeft.bottom
             left: left.right
             bottom: bottomRight.top
         }
         width: bottomRight.width
         source: "images/side-fade.png"
     }

     Image {
         id: topFade
         anchors {
             top: top.bottom
             left: topLeft.right
             right: bottomRight.left
         }
         height: topLeft.height
         source: "images/top-fade.png"
     }

     Image {
         id: rightFade
         anchors {
             top: topLeft.bottom
             right: right.left
             bottom: bottomRight.top
         }
         width: topLeft.width
         source: "images/side-fade.png"
         rotation: 180
     }

     Image {
         id: bottomFade
         anchors {
             bottom: bottom.top
             left: topLeft.right
             right: bottomRight.left
         }
         height: bottomLeft.width
         source: "images/top-fade.png"
         rotation: 180
     }
 }
