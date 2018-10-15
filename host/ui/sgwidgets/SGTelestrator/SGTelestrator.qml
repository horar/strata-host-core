import QtQuick 2.9
import QtQuick.Controls 2.3

Item {
    id: root
    anchors.fill: parent

    property var paths: ({ "pathList": [], "count": 0 })

    Rectangle {
        id: canvasContainer
        width: root.width - 100
        height: root.height
        anchors {
            left: root.left
        }

        Canvas {
            id: canvas

            property int startX;
            property int startY;
            property int finishX;
            property int finishY;
            property color currentColor: "#000"
            property real lineThickness: 5

            anchors {
                fill: canvasContainer
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.lineJoin = ctx.lineCap = 'round';

                for (var i = 0; i < root.paths.pathList.length; i++) {
                    if (root.paths.pathList[i].width !== undefined)
                        ctx.lineWidth = root.paths.pathList[i].width;

                    if (root.paths.pathList[i].path !== undefined)
                        ctx.path = root.paths.pathList[i].path;

                    if (root.paths.pathList[i].stroke !== undefined) {
                        ctx.strokeStyle = root.paths.pathList[i].stroke;
                        ctx.stroke();
                    }
                }
            }

            MouseArea {
                id: mouseArea
                property int skipCounter: 1
                property int skipMouseMovements: 4

                anchors.fill: canvas

                onPressed: {
                    canvas.startX = mouseX;
                    canvas.startY = mouseY;

                    root.paths.pathList[root.paths.count] = {
                        "stroke" : "" + canvas.currentColor,
                        "width" : canvas.lineThickness,
                        "path" : "M " + canvas.startX + " " + canvas.startY
                    }
                }

                onPositionChanged: {
                    if (skipCounter % skipMouseMovements === 0){
                        canvas.finishX = mouseX;
                        canvas.finishY = mouseY;

                        root.paths.pathList[root.paths.count].path = root.paths.pathList[root.paths.count].path.concat(" L " + canvas.finishX + " " + canvas.finishY)

                        canvas.requestPaint();
                        skipCounter = 1
                    } else {
                        skipCounter++
                    }
                }

                onReleased: {
                    root.paths.count++
                    // Send paths to server here, not updated live as beign drawn
                }
            }
        }
    }

    Rectangle {
        id: optionsContainer
        height: root.height
        anchors {
            left: canvasContainer.right
            right: root.right
        }
        border {
            width: 1
            color: "lightgrey"
        }

        Column{
            Row {
                SGColorChip {
                    color: "white"
                    onClicked: canvas.currentColor = color;
                }
                SGColorChip {
                    color: "black"
                    onClicked: canvas.currentColor = color;
                }
            }

            Row {
                SGColorChip {
                    color: "grey"
                    onClicked: canvas.currentColor = color;
                }
                SGColorChip {
                    color: "dodgerblue"
                    onClicked: canvas.currentColor = color;
                }
            }

            Row {
                SGColorChip {
                    color: "lawngreen"
                    onClicked: canvas.currentColor = color;
                }
                SGColorChip {
                    color: "gold"
                    onClicked: canvas.currentColor = color;
                }
            }

            Row {
                SGColorChip {
                    color: "darkorange"
                    onClicked: canvas.currentColor = color;
                }
                SGColorChip {
                    color: "crimson"
                    onClicked: canvas.currentColor = color;
                }
            }

            Row {
                SGLineThickness {
                    lineThickness: 1
                    onClicked: canvas.lineThickness = thickness;
                }

                SGLineThickness {
                    lineThickness: 3
                    onClicked: canvas.lineThickness = thickness;
                }

                SGLineThickness {
                    lineThickness: 6
                    onClicked: canvas.lineThickness = thickness;
                }

                SGLineThickness {
                    lineThickness: 9
                    onClicked: canvas.lineThickness = thickness;
                }

                SGLineThickness {
                    lineThickness: 12
                    onClicked: canvas.lineThickness = thickness;
                }
            }

            Row {
                Button {
                    onClicked: {
                        root.paths.pathList = []
                        root.paths.count = 0
                        canvas.requestPaint()
                    }
                    text: "Clear All"
                }
            }
        }
    }
}
