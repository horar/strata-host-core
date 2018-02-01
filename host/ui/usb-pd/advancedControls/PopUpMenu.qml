import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

ComboBox {
    id:control
    font.family: "helvetica"
    font.pointSize: smallFontSize
    height:15
    width:30

    property color backgroundColor: "#838484"

    //this is used by the PopUp to determine what font to use
    delegate: ItemDelegate {
            width: parent.width
            height:15
            contentItem: Text {
                text: modelData
                color: highlighted? "#D8D8D8" :"black"
                font: parent.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            onClicked:{
                //here's where a click on a new selection should be handled
                //implementationInterfaceBinding.setMaximumPortPower(2,modelData)
                console.log("clicked:", modelData)
            }

            highlighted: parent.highlightedIndex === index
        }

    //this just draws the drop down indicator triangle
    indicator: Canvas {
        id: canvas
        x: control.width /*- width*/ - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 8
        height: 6
        contextType: "2d"

        Connections {
            target: control
            onPressedChanged: canvas.requestPaint()
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = "black";
            context.fill();
        }
    }

    //the background of the box initially shown
    background: Rectangle {
            implicitWidth: 15
            implicitHeight: 10
            color: parent.backgroundColor
            border.color: parent.backgroundColor
        }

    //the text shown in the box (i.e. not the menu text)
    contentItem: Text {
            leftPadding: 0
            rightPadding: parent.indicator.width + parent.spacing
            text: parent.displayText
            font: parent.font
            color: parent.pressed ? "#17a81a" : "#D8D8D8"
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

    //this governs the rectangle that pops up when the comboBox is clicked
    popup: Popup {
        y: control.height - 1
        width: parent.width *2
        implicitHeight: contentItem.implicitHeight
        padding: 1
        font.family: "helvetica"
        font.pointSize: smallFontSize
        topPadding: -8

        contentItem: ListView {
            id: popupListView
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            highlightFollowsCurrentItem: false // false so the highlight delegate can control how the highlight is moved.
            highlight: Rectangle {
                width: backgroundRectangle.width;
                height: contentItem.implicitHeight *1.2
                color: "darkgrey"
                y: popupListView.currentItem.y + contentItem.height/2;
                Behavior on y { SpringAnimation { spring: 2; damping: 0.1 } }
            }

        }

        background: Rectangle {
            id:backgroundRectangle
            color: control.backgroundColor
            border.color: control.backgroundColor
        }
    }
}
