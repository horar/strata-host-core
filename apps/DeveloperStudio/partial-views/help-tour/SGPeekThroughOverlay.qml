import QtQuick 2.12
import "qrc:/js/help_layout_manager.js" as Help

Item {
     id: root
     visible: false
     z: 50
     anchors.fill: parent

     property alias index: toolTipPopup.index
     property alias description: toolTipPopup.description
     property alias fontSizeMultiplier: toolTipPopup.fontSizeMultiplier
     property alias toolTipPopup: toolTipPopup
     property real globalOpacity: .5

     function setTarget(target) {
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

         updateAlignment()
     }

     function updateAlignment() {
         // apply default alignment settings:
         toolTipBackgroundItem.anchors.bottom = undefined
         toolTipBackgroundItem.anchors.right = undefined
         toolTipBackgroundItem.anchors.left = undefined
         toolTipBackgroundItem.anchors.horizontalCenter = bottomFade.horizontalCenter
         toolTipBackgroundItem.anchors.top = bottomFade.bottom
         toolTipPopup.horizontalAlignment = "center"
         toolTipPopup.arrowOnTop = true

         // change alignment if default alignment extends beyond window edges
         if ( toolTipBackgroundItem.x < 0 ) {
             toolTipBackgroundItem.anchors.horizontalCenter = undefined
             toolTipBackgroundItem.anchors.left = bottomFade.horizontalCenter
             toolTipPopup.horizontalAlignment = "left"
         } else if ( toolTipBackgroundItem.x + toolTipBackgroundItem.width >= root.parent.width ) {
             toolTipBackgroundItem.anchors.horizontalCenter = undefined
             toolTipBackgroundItem.anchors.right = bottomFade.horizontalCenter
             toolTipPopup.horizontalAlignment = "right"
         }
         if ( toolTipBackgroundItem.y + toolTipBackgroundItem.height >= root.parent.height ) {
             toolTipBackgroundItem.anchors.top = undefined
             toolTipBackgroundItem.anchors.bottom = topFade.top
             toolTipPopup.arrowOnTop = false
         }
     }

     function restoreFocus(){
        tourControl.forceActiveFocus()
     }

     MouseArea {
         anchors {
             fill: root
         }
         acceptedButtons: Qt.AllButtons
         onClicked: tourControl.close()
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

     Item {
         id: toolTipBackgroundItem
         width: toolTipPopup.width
         height: toolTipPopup.height
         focus: true
         // anchors set dynamically in setTarget

         onHeightChanged: {
             if (visible) {
                updateAlignment()
             }
         }

         SGToolTipPopup {
             id: toolTipPopup
             color: "white"
             visible: root.visible
             width: 360
             height: tourControl.implicitHeight + (padding * 2)

             property int index
             property string description
             property real fontSizeMultiplier: 1

             SGTourControl {
                 id: tourControl
                 index: toolTipPopup.index
                 description: toolTipPopup.description
                 fontSizeMultiplier: toolTipPopup.fontSizeMultiplier
                 width: parent.width
             }
         }
     }
 }
