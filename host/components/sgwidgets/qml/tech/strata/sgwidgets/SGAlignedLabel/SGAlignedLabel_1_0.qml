import QtQuick 2.9
import tech.strata.sgwidgets 1.0

/*  -----------------------
    Alignment Enum Diagram:
    -----------------------

       CornerTopLeft  SideTopLeft        SideTopCenter       SideTopRight  CornerTopRight

         SideLeftTop  |‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|  SideRightTop
                      |                                                 |
      SideLeftCenter  |             target (labelled widget)            |  SideRightCenter
                      |                                                 |
      SideLeftBottom  |_________________________________________________|  SideRightBottom

    CornerBottomLeft  SideBottomleft   SideBottomCenter   SideBottomRight  CornerBottomRight
*/

Item {
    id: root

    property Item target: null
    property int alignment: 15
    property real margin: 5
    property real overrideLabelWidth: -1

    property alias text: label.text
    property alias alternativeColorEnabled: label.alternativeColorEnabled
    property alias color: label.color
    property alias implicitColor: label.implicitColor
    property alias alternativeColor: label.alternativeColor
    property alias fontSizeMultiplier: label.fontSizeMultiplier
    property alias font: label.font
    property alias horizontalAlignment: label.horizontalAlignment
    property alias contentHeight: label.contentHeight
    property alias contentWidth: label.contentWidth

    enum Alignment {
        CornerTopLeft,

        SideLeftTop,
        SideLeftCenter,
        SideLeftBottom,

        CornerBottomLeft,

        SideBottomLeft,
        SideBottomCenter,
        SideBottomRight,

        CornerBottomRight,

        SideRightBottom,
        SideRightCenter,
        SideRightTop,

        CornerTopRight,

        SideTopRight,
        SideTopCenter,
        SideTopLeft
    }

    onAlignmentChanged: {
        setAnchors()
    }

    onTargetChanged: {
        setAnchors()
    }

    Component.onCompleted: setAnchors()

    SGText {
        id: label
        height: text === "" ? 0 : contentHeight
        text: ""
        width: overrideLabelWidth > 0 ? overrideLabelWidth : contentWidth
        horizontalAlignment: {
            switch (root.alignment) {
            case SGAlignedLabel.SideLeftTop:
            case SGAlignedLabel.SideLeftCenter:
            case SGAlignedLabel.SideLeftBottom:
            case SGAlignedLabel.CornerTopLeft:
            case SGAlignedLabel.CornerBottomLeft:
            case SGAlignedLabel.SideTopLeft:
            case SGAlignedLabel.SideBottomLeft:
                return Text.AlignLeft

            case SGAlignedLabel.SideBottomCenter:
            case SGAlignedLabel.SideTopCenter:
                return Text.AlignHCenter

            case SGAlignedLabel.SideBottomRight:
            case SGAlignedLabel.CornerBottomRight:
            case SGAlignedLabel.CornerTopRight:
            case SGAlignedLabel.SideRightBottom:
            case SGAlignedLabel.SideRightCenter:
            case SGAlignedLabel.SideRightTop:
            case SGAlignedLabel.SideTopRight:
                return Text.AlignLeft
            }
        }
    }

    function clearAnchors (object) {
        object.anchors.right = object.anchors.bottom = object.anchors.top = object.anchors.left = object.anchors.verticalCenter = object.anchors.horizontalCenter = undefined
        object.anchors.rightMargin = object.anchors.leftMargin = object.anchors.topMargin = object.anchors.bottomMargin = 0
        object.x = 0
        object.y = 0
    }

    function setAnchors (){
        if (target && label.text !== "") {
            clearAnchors(target)
            clearAnchors(label)
            switch(root.alignment) {
            case SGAlignedLabel.SideLeftTop:
                target.anchors.left = label.right
                target.anchors.leftMargin = margin
                label.anchors.top = target.top
                root.implicitWidth = Qt.binding(function () {return target.width + margin + label.width})
                root.implicitHeight = Qt.binding(function () {return Math.max(target.height, label.height)})
                break;
            case SGAlignedLabel.SideLeftCenter:
                target.anchors.verticalCenter = root.verticalCenter
                target.anchors.left = label.right
                target.anchors.leftMargin = margin
                label.anchors.verticalCenter = target.verticalCenter
                root.implicitWidth = Qt.binding(function () {return target.width + margin + label.width})
                root.implicitHeight = Qt.binding(function () {return Math.max(target.height, label.height)})
                break;
            case SGAlignedLabel.SideLeftBottom:
                target.anchors.bottom = root.bottom
                target.anchors.left = label.right
                target.anchors.leftMargin = margin
                label.anchors.bottom = target.bottom
                root.implicitWidth = Qt.binding(function () {return target.width + margin + label.width})
                root.implicitHeight = Qt.binding(function () {return Math.max(target.height, label.height)})
                break;
            case SGAlignedLabel.SideRightTop:
                label.anchors.left = target.right
                label.anchors.leftMargin = margin
                label.anchors.top = target.top
                root.implicitWidth = Qt.binding(function () {return target.width + margin + label.width})
                root.implicitHeight = Qt.binding(function () {return Math.max(target.height, label.height)})
                break;
            case SGAlignedLabel.SideRightCenter:
                target.anchors.verticalCenter = root.verticalCenter
                label.anchors.left = target.right
                label.anchors.leftMargin = margin
                label.anchors.verticalCenter = target.verticalCenter
                root.implicitWidth = Qt.binding(function () {return target.width + margin + label.width})
                root.implicitHeight = Qt.binding(function () {return Math.max(target.height, label.height)})
                break;
            case SGAlignedLabel.SideRightBottom:
                target.anchors.bottom = root.bottom
                label.anchors.bottom = target.bottom
                label.anchors.left = target.right
                label.anchors.leftMargin = margin
                root.implicitWidth = Qt.binding(function () {return target.width + margin + label.width})
                root.implicitHeight = Qt.binding(function () {return Math.max(target.height, label.height)})
                break;
            case SGAlignedLabel.SideTopLeft:
                target.anchors.top = label.bottom
                target.anchors.topMargin = margin
                root.implicitWidth = Qt.binding(function () {return Math.max(target.width, label.width)})
                root.implicitHeight = Qt.binding(function () {return target.height + margin + label.height})
                break;
            case SGAlignedLabel.SideTopCenter:
                target.anchors.horizontalCenter = root.horizontalCenter
                label.anchors.horizontalCenter = target.horizontalCenter
                target.anchors.top = label.bottom
                target.anchors.topMargin = margin
                root.implicitWidth = Qt.binding(function () {return Math.max(target.width, label.width)})
                root.implicitHeight = Qt.binding(function () {return target.height + margin + label.height})
                break;
            case SGAlignedLabel.SideTopRight:
                target.anchors.right = root.right
                label.anchors.right = target.right
                target.anchors.top = label.bottom
                target.anchors.topMargin = margin
                root.implicitWidth = Qt.binding(function () {return Math.max(target.width, label.width)})
                root.implicitHeight = Qt.binding(function () {return target.height + margin + label.height})
                break;
            case SGAlignedLabel.SideBottomLeft:
                label.anchors.topMargin = margin
                label.anchors.top = target.bottom
                root.implicitWidth = Qt.binding(function () {return Math.max(target.width, label.width)})
                root.implicitHeight = Qt.binding(function () {return target.height + margin + label.height})
                break;
            case SGAlignedLabel.SideBottomCenter:
                target.anchors.horizontalCenter = root.horizontalCenter
                label.anchors.horizontalCenter = target.horizontalCenter
                label.anchors.topMargin = margin
                label.anchors.top = target.bottom
                root.implicitWidth = Qt.binding(function () {return Math.max(target.width, label.width)})
                root.implicitHeight = Qt.binding(function () {return target.height + margin + label.height})
                break;
            case SGAlignedLabel.SideBottomRight:
                target.anchors.right = root.right
                label.anchors.right = target.right
                label.anchors.topMargin = margin
                label.anchors.top = target.bottom
                root.implicitWidth = Qt.binding(function () {return Math.max(target.width, label.width)})
                root.implicitHeight = Qt.binding(function () {return target.height + margin + label.height})
                break;
            case SGAlignedLabel.CornerBottomRight:
                label.anchors.topMargin = label.anchors.leftMargin = margin
                label.anchors.top = target.bottom
                label.anchors.left = target.right
                root.implicitWidth = Qt.binding(function () {return target.width + margin + label.width})
                root.implicitHeight = Qt.binding(function () {return target.height + margin + label.height})
                break;
            case SGAlignedLabel.CornerBottomLeft:
                target.anchors.left = label.right
                label.anchors.topMargin = target.anchors.leftMargin = margin
                label.anchors.top = target.bottom
                root.implicitWidth = Qt.binding(function () {return target.width + margin + label.width})
                root.implicitHeight = Qt.binding(function () {return target.height + margin + label.height})
                break;
            case SGAlignedLabel.CornerTopRight:
                label.anchors.left = target.right
                target.anchors.top = label.bottom
                label.anchors.leftMargin = target.anchors.topMargin = margin
                root.implicitWidth = Qt.binding(function () {return target.width + margin + label.width})
                root.implicitHeight = Qt.binding(function () {return target.height + margin + label.height})
                break;
            default: // SGAlignedLabel.CornerTopLeft
                target.anchors.left = label.right
                target.anchors.leftMargin = target.anchors.topMargin = margin
                target.anchors.top = label.bottom
                root.implicitWidth = Qt.binding(function () {return target.width + margin + label.width})
                root.implicitHeight = Qt.binding(function () {return target.height + margin + label.height})
                break;
            }
        }
    }
}
