import QtQuick 2.9

Item {
     id: root
     width: left.width + top.width + right.width
     height: left.height
     visible: false
     z: 50

     function setTarget(target, fill) {
         var remappedTarget = target.mapToItem(fill, 0, 0)//target.width/2, target.height/2)
         mockTarget.x = remappedTarget.x //- (mockTarget.width/2)
         mockTarget.y = remappedTarget.y// - (mockTarget.height/2)
//         mockTarget.x = target.x //- (mockTarget.width/2)
//         mockTarget.y = target.y// - (mockTarget.height/2)
         mockTarget.width = target.width
         mockTarget.height = target.height
         windowHeight = fill.height
         windowWidth = fill.width
     }

     property alias fill: root.parent
     property alias index: toolTipPopup.index
     property alias description: toolTipPopup.description

     property real windowHeight
     property real windowWidth
     property real globalOpacity: .5

     MouseArea {
         anchors {
             fill: root
         }
         onClicked: root.visible = false
     }

     Item {
         id: mockTarget
     }

     Rectangle {
         id: left
         color: "black"
         anchors {
             right: leftFade.left
             verticalCenter: leftFade.verticalCenter
         }
         width: windowWidth
         height: windowHeight * 2
         opacity: root.globalOpacity
     }

     Rectangle {
         id: right
         color: "black"
         anchors {
             left: rightFade.right
             verticalCenter: rightFade.verticalCenter
         }
         width: windowWidth
         height: windowHeight * 2
         opacity: root.globalOpacity
     }

     Rectangle {
         id: top
         color: "black"
         anchors {
             bottom: topFade.top
             right: right.left
             left: left.right
         }
         height: windowHeight
         opacity: root.globalOpacity
     }

     Rectangle {
         id: bottom
         color: "black"
         anchors {
             top: bottomFade.bottom
             right: right.left
             left: left.right
         }
         height: windowHeight
         opacity: root.globalOpacity
     }

     Image {
         id: topLeft
         anchors {
             left: left.right
             top: top.bottom
         }
         height: 30
         width: 30
         source: "images/corner-fade.png"
         opacity: root.globalOpacity
     }

     Image {
         id: topRight
         anchors {
             right: right.left
             top: top.bottom
         }
         height: 30
         width: 30
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
         height: 30
         width: 30
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
         height: 30
         width: 30
         source: "images/corner-fade.png"
         transform: Rotation { origin.x: bottomLeft.height/2; origin.y: bottomLeft.height/2; angle: -90}
         opacity: root.globalOpacity
     }

     Image {
         id: leftFade
         anchors {
             top: topLeft.bottom
             right: mockTarget.left
             bottom: bottomRight.top
         }
         width: 30
         source: "images/side-fade.png"
         opacity: root.globalOpacity
     }

     Image {
         id: topFade
         anchors {
             bottom: mockTarget.top
             left: topLeft.right
             right: bottomRight.left
         }
         height: 30
         source: "images/top-fade.png"
         opacity: root.globalOpacity
     }

     Image {
         id: rightFade
         anchors {
             top: topLeft.bottom
             left: mockTarget.right
             bottom: bottomRight.top
         }
         width: 30
         source: "images/side-fade.png"
         rotation: 180
         opacity: root.globalOpacity
     }

     Image {
         id: bottomFade
         anchors {
             top: mockTarget.bottom
             left: topLeft.right
             right: bottomRight.left
         }
         height: 30
         source: "images/top-fade.png"
         rotation: 180
         opacity: root.globalOpacity
     }

     SGToolTipPopup {
         id: toolTipPopup
         showOn: true
         anchors {
             top: bottomFade.bottom
             horizontalCenter: bottomFade.horizontalCenter
         }
         reverseDirection: true
         color: "white"
         property int index
         property string description

         content: SGTourControl {
             id: tourControl
             onClose: root.visible = false
             index: toolTipPopup.index
             description: toolTipPopup.description
         }
     }
 }
