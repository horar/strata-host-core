import QtQuick 2.12
import tech.strata.sgwidgets 0.9

Item {
     id: root
     visible: false
     anchors.fill: parent

     function setTarget(target, fill) {
         mockTarget.x = Qt.binding(function() {
             target.x // dummy to force evaluation
             return target.mapToItem(root.parent, 0, 0).x
         })
         mockTarget.y = Qt.binding(function() {
             target.y // dummy to force evaluation
             return target.mapToItem(root.parent, 0, 0).y
         })
         mockTarget.width = Qt.binding(function() { return target.width })
         mockTarget.height = Qt.binding(function() { return target.height })

         // apply default alignment settings:
         toolTipPopup.anchors.bottom = undefined
         toolTipPopup.anchors.right = undefined
         toolTipPopup.anchors.left = undefined
         toolTipPopup.anchors.horizontalCenter = bottomFade.horizontalCenter
         toolTipPopup.anchors.top = bottomFade.bottom
         toolTipPopup.horizontalAlignment = "center"
         toolTipPopup.arrowOnTop = true

         // change alignment if default alignment extends beyond window edges
         if ( toolTipPopup.x < 0 ) {
             toolTipPopup.anchors.horizontalCenter = undefined
             toolTipPopup.anchors.left = bottomFade.horizontalCenter
             toolTipPopup.horizontalAlignment = "left"
         } else if ( toolTipPopup.x + toolTipPopup.width > fill.width ) {
             toolTipPopup.anchors.horizontalCenter = undefined
             toolTipPopup.anchors.right = bottomFade.horizontalCenter
             toolTipPopup.horizontalAlignment = "right"
         }
         if ( toolTipPopup.y + toolTipPopup.height > fill.height ) {
             toolTipPopup.anchors.top = undefined
             toolTipPopup.anchors.bottom = topFade.top
             toolTipPopup.arrowOnTop = false
         }
     }

     property alias index: toolTipPopup.index
     property alias description: toolTipPopup.description

     property real globalOpacity: .5

     MouseArea {
         anchors {
             fill: root
         }
         onClicked: toolTipPopup.contentItem.close()
         onWheel: {} // Prevent views behind from scrolling, which will misalign the peekthrough
     }

     Item {
         id: mockTarget

         onVisibleChanged: {
             if (visible === false) {
                 // remove bindings if no longer required
                 x = 0
                 y = 0
                 width = 0
                 height = 0
             }
         }
     }

     Rectangle {
         id: left
         color: "black"
         anchors {
             right: leftFade.left
             top: root.top
             bottom: root.bottom
             left: root.left
         }

         opacity: root.globalOpacity
     }

     Rectangle {
         id: right
         color: "black"
         anchors {
             left: rightFade.right
             right: root.right
             bottom: root.bottom
             top: root.top
         }
         opacity: root.globalOpacity
     }

     Rectangle {
         id: top
         color: "black"
         anchors {
             bottom: topFade.top
             right: right.left
             left: left.right
             top: root.top
         }
         opacity: root.globalOpacity
     }

     Rectangle {
         id: bottom
         color: "black"
         anchors {
             top: bottomFade.bottom
             right: right.left
             left: left.right
             bottom: root.bottom
         }
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
         // anchors and arrow alignment dynamically in setTarget
         color: "white"
         property int index
         property string description

         content: SGTourControl {
             id: tourControl
             index: toolTipPopup.index
             description: toolTipPopup.description
         }
     }
 }
