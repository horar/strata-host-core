import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

ComboBox {
    id:control
    // model: ["15","27", "36", "45","60","100"]

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

//                        indicator: Canvas {
//                                id: canvas
//                                x: port2MaxPowerCombo.width /*- width*/ - port2MaxPowerCombo.rightPadding
//                                y: port2MaxPowerCombo.topPadding + (port2MaxPowerCombo.availableHeight - height) / 2
//                                width: 12
//                                height: 8
//                                contextType: "2d"

//                                Connections {
//                                    target: port2MaxPowerCombo
//                                    onPressedChanged: canvas.requestPaint()
//                                }

//                                onPaint: {
//                                    context.reset();
//                                    context.moveTo(0, 0);
//                                    context.lineTo(width, 0);
//                                    context.lineTo(width / 2, height);
//                                    context.closePath();
//                                    context.fillStyle = "black";
//                                    context.fill();
//                                }
//                            }

    background: Rectangle {
            implicitWidth: 15
            implicitHeight: 10
            color: parent.backgroundColor
            border.color: parent.backgroundColor
        }

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

    popup: Popup {
        y: parent.height - 1
        width: parent.width *2
        implicitHeight: contentItem.implicitHeight
        padding: 1
        font.family: "helvetica"
        font.pointSize: smallFontSize
        //color: "#D8D8D8"

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: control.backgroundColor
            border.color: control.backgroundColor
        }
    }
}
