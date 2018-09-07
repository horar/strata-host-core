import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "calculation.js" as Calc
import "component_source.js" as ComponentSource

Item {
    id: root

    GraphAndCircuit {
        id: efficiency
        anchors {
            top: root.top
            left: root.left
            right: root.right
        }
        height: 350
        dataLine1Color: "tomato"
        dataLine2Color: "#0088FF"
    }

    TabBar {
        id: bar
        anchors {
            top: efficiency.bottom
            left: root.left
            right: root.right
        }
        currentIndex: 0

        TabButton {
            id: circuit1Button
            text: "Circuit 1"

            Canvas {
                id: circuit1Color
                anchors {
                    fill: circuit1Button
                }
                contextType: "2d"

                property real slideWidth: circuit1Button.checked ? 0.15 : 0
                onSlideWidthChanged: circuit1Color.requestPaint()
                Behavior on slideWidth { NumberAnimation { duration: 100 } }

                onPaint: {
                    context.reset();
                    context.lineWidth = 1
                    context.fillStyle = efficiency.dataLine1Color;

                    context.beginPath();
                    context.moveTo(width * (1-slideWidth), 0);
                    context.lineTo(width, 0);
                    context.lineTo(width, height);
                    context.lineTo(width * (1-slideWidth) - height, height);
                    context.closePath();
                    context.fill();
                }
            }
        }

        TabButton {
            id: circuit2Button
            text: "Circuit 2"

            Canvas {
                id: circuit2Color
                anchors {
                    fill: circuit2Button
                }
                contextType: "2d"

                property real slideWidth: circuit2Button.checked ? 0.15 : 0
                onSlideWidthChanged: circuit2Color.requestPaint()
                Behavior on slideWidth { NumberAnimation { duration: 100 } }

                onPaint: {
                    context.reset();
                    context.lineWidth = 1
                    context.fillStyle = efficiency.dataLine2Color;

                    context.beginPath();
                    context.moveTo(width * (1-slideWidth), 0);
                    context.lineTo(width, 0);
                    context.lineTo(width, height);
                    context.lineTo(width * (1-slideWidth) - height, height);
                    context.closePath();
                    context.fill();
                }
            }
        }
/*
        TabButton {
            text: "Power Loss Components"
        }

        TabButton {
            text: "MOSFET Selector"
        }
*/
        TabButton {
            text: "MOSFETs"
        }

        TabButton {
            text: "Drivers"
        }
    }

    Rectangle {
        id: resizeDivider
        height: 3
        width: bar.width
        color: "#353637"
        anchors {
            bottom: efficiency.bottom
        }

        Rectangle {
            height: resizeDivider.height - 2
            width: resizeDivider.width - 2
            color: "white"
            anchors {
                verticalCenter: resizeDivider.verticalCenter
                horizontalCenter: resizeDivider.horizontalCenter
            }
        }

        MouseArea {
            id: resizeArea
            anchors {
                fill: resizeDivider
            }
            cursorShape: Qt.SizeVerCursor
            property variant clickPos: "1,1" // @disable-check M311 // Ignore 'use string' (M311) QtCreator warning

            onPressed: {
                clickPos = Qt.point(mouse.x,mouse.y)
            }

            onPositionChanged: {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
//                popoutWindow.width += delta.x;
                efficiency.height += delta.y;
            }
        }
    }

    StackLayout {
        id: stack
        currentIndex: bar.currentIndex
        anchors {
            top: bar.bottom
            bottom: root.bottom
            left: root.left
            right: root.right
        }
        property int previousIndex: 0
        onCurrentIndexChanged: {
            if ( (previousIndex === 0 || previousIndex === 1) && (currentIndex === 0 || currentIndex === 1) ){
                flashIn.start()
            }
            previousIndex = currentIndex
        }

        Circuit {
            id: circuit1
            onUpdate: Calc.calculate(circuit1, efficiency.series1)
        }

        Circuit {
            id: circuit2
            onUpdate: Calc.calculate(circuit2, efficiency.series2)
            highMosfetIndex: 1
        }

       /* Item {
            Text {
                text: qsTr("Power Loss Components Here")
            }
        }

        Item {
            Text {
                text: qsTr("MOSFET Selector Here")
            }
        }  */

        Mosfets { }

        Drivers { }
    }

    PropertyAnimation {
        id: flashIn
        target: transitioner
        property: "opacity"
        from: 0
        to: 1
        onStopped: flashOut.start()
        duration: 40
    }

    PropertyAnimation {
        id: flashOut
        target: transitioner
        property: "opacity"
        from: 1
        to: 0
        duration: flashIn.duration
    }

    Rectangle {
        id: transitioner
        color: "white"
        anchors {
            top: stack.top
            bottom: stack.bottom
            left: stack.left
            right: stack.right
        }
        z:20
        opacity: 0
    }
}
