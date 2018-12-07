import QtQuick 2.9

Item {
     id: root
     width: fill.width
     height: fill.height
     visible: false

     signal clicked()

     property var remappedTarget
     property var remappedFill: fill.mapToItem(target, 0, 0)
     Component.onCompleted: {
         remappedTarget = target.mapToItem(fill, 0, 0)
     }

     property int padding: 60
     property real globalOpacity: .5

     x: remappedFill.x
     y: remappedFill.y

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
         width: Math.max(0, remappedTarget.x - padding/2)
         opacity: root.globalOpacity
     }

     Rectangle {
         id: right
         color: "black"
         anchors {
             top: root.top
             right: root.right
             bottom: root.bottom
         }
         width: Math.max(0, root.width - target.width - left.width - padding)
         opacity: root.globalOpacity
     }

     Rectangle {
         id: top
         color: "black"
         anchors {
             top: root.top
             right: right.left
             left: left.right
         }
         height: remappedTarget.y - padding/2
         opacity: root.globalOpacity
     }

     Rectangle {
         id: bottom
         color: "black"
         anchors {
             bottom: root.bottom
             right: right.left
             left: left.right
         }
         height: root.height - target.height - top.height - padding
         opacity: root.globalOpacity
     }

     Image {
         id: topLeft
         anchors {
             left: left.right
             top: top.bottom
         }
         height: Math.min(30, (target.height + padding)/2)
         width: Math.min(30, (target.width + padding)/2)
         source: "images/corner-fade.png"
         opacity: root.globalOpacity
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
         opacity: root.globalOpacity
     }

     Image {
         id: bottomRight
         anchors {
             right: right.left
             bottom: bottom.top
         }
         height: Math.min(30, (target.height + padding)/2)
         width: Math.min(30, (target.width+ padding)/2)
         source: "images/corner-fade.png"
         rotation: 180
         opacity: root.globalOpacity
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
         opacity: root.globalOpacity
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
         opacity: root.globalOpacity
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
         opacity: root.globalOpacity
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
         opacity: root.globalOpacity
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
         opacity: root.globalOpacity
     }


     SGToolTipPopup {
         showOn: true
         anchors {
             top: bottomFade.bottom
             horizontalCenter: bottomFade.horizontalCenter
         }
         reverseDirection: true

         content: Text {
             id: helpText
             color:"white"
             font {
                 pixelSize: 20
                 }
             text: "<b>THIS IS A TEST</b>"
         }
     }
 }
