import QtQuick 2.9
import QtQuick.Controls 2.3

Item {
    id: root

    property var paths: ({ "pathList": [], "count": 0 })

    Connections {
        target: server
        onNewPathChanged: {
            if ( paths.pathList[paths.count] !== server.newPath ) {
                paths.pathList[paths.count] = server.newPath
                paths.count++
                canvas.requestPaint()
            }
        }
    }

    Connections {
        target: server
        onClearView: {
            root.clear()
        }
    }

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
            property bool arrowMode: false
            property bool boxMode: false
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

                        if (canvas.arrowMode) {
                            var xx = Math.round(canvas.finishX + 0.25*( (canvas.startX - canvas.finishX) * 0.7071068 + (canvas.startY - canvas.finishY) * 0.7071068 ))
                            var yy = Math.round(canvas.finishY + 0.25*( (canvas.startY - canvas.finishY) * 0.7071068 - (canvas.startX - canvas.finishX) * 0.7071068 ))
                            var xxx = Math.round(canvas.finishX + 0.25*( (canvas.startX - canvas.finishX) * 0.7071068 - (canvas.startY - canvas.finishY) * 0.7071068 ))
                            var yyy = Math.round(canvas.finishY + 0.25*( (canvas.startY - canvas.finishY) * 0.7071068 + (canvas.startX - canvas.finishX) * 0.7071068 ))

                            root.paths.pathList[root.paths.count].path = "M " + canvas.startX + " " + canvas.startY +
                                    " L " + canvas.finishX + " " + canvas.finishY +
                                    " L " + xx + " " + yy +
                                    " M " + canvas.finishX + " " + canvas.finishY +
                                    " L " + xxx + " " + yyy
                        } else if (canvas.boxMode) {
                            root.paths.pathList[root.paths.count].path = "M " + canvas.startX + " " + canvas.startY +
                                    " L " + canvas.startX + " " + canvas.finishY +
                                    " L " + canvas.finishX + " " + canvas.finishY +
                                    " L " + canvas.finishX + " " + canvas.startY + " z"
                        } else {
                            root.paths.pathList[root.paths.count].path = root.paths.pathList[root.paths.count].path.concat(" L " + canvas.finishX + " " + canvas.finishY)
                        }

                        canvas.requestPaint();
                        skipCounter = 1
                    } else {
                        skipCounter++
                    }
                }

                onReleased: {
                    console.log("JSON sent: ", JSON.stringify(root.paths.pathList[root.paths.count]))
                    server.newPath = root.paths.pathList[root.paths.count];
                    root.paths.count++
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

                SGLineThickness {
                    lineThickness: 15
                    onClicked: canvas.lineThickness = thickness;
                }

                SGLineThickness {
                    lineThickness: 18
                    onClicked: canvas.lineThickness = thickness;
                }
            }


            Row {
                Button {
                    checkable: true
                    checked: canvas.boxMode
                    onClicked: {
                        canvas.boxMode = !canvas.boxMode
                        if (canvas.arrowMode && canvas.boxMode) { canvas.arrowMode = false }
                    }
                    text: "Box Mode"
                }
            }

            Row {
                Button {
                    checkable: true
                    checked: canvas.arrowMode
                    onClicked: {
                        canvas.arrowMode = !canvas.arrowMode
                        if (canvas.boxMode && canvas.arrowMode) { canvas.boxMode = false }
                    }
                    text: "Arrow Mode"
                }
            }

            Row {
                Button {
                    onClicked: {
                        server.clearView()
                    }
                    text: "Clear All"
                }
            }
        }
    }

    function clear () {
        root.paths.pathList = []
        root.paths.count = 0
        canvas.requestPaint()
    }
}
