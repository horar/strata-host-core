import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import tech.strata.sgwidgets 0.9

// StatusLogBox wrapper that allows text selection/copying across delegates

SGStatusLogBox {
    id: root

    filterRole: "message"   // this role is what is cmd/ctrl-f filters on
    copyRole: "selection"   // this role is what is copied from selected/copied ListElements
    listViewMouse.cursorShape: Qt.IBeamCursor
    listViewMouse.drag.target: dragitem

    //  Overrides built-in listElementTemplate that enables mouse text selection ability
    listElementTemplate: {
        "message": "",
        "id": 0,
        "state": "noneSelected",        // required role for text selection functionality
        "selection": "",                // required role for text selection functionality
        "selectionStart": 0,            // required role for text selection functionality
        "selectionEnd": 0,              // required role for text selection functionality
    }

    property int indexDragStarted: -1
    property bool selecting: false

    signal deselectAll()
    signal selectInBetween(int indexDragEnded)

    onDeselectAll: {
        for (var i = 0; i < listView.model.count; i++) {
            listView.model.get(i).state = "noneSelected"
        }
    }

    onSelectInBetween: {
        var start
        var end
        if (indexDragEnded > root.indexDragStarted) {
            start = root.indexDragStarted + 1
            end = indexDragEnded
        } else {
            start = indexDragEnded + 1
            end = root.indexDragStarted
        }

        for (var i = 0; i < listView.model.count; i++) {
            var listElement = listView.model.get(i);
            if (i >= start && i < end) {
                listElement.state = "allSelected"
            } else if (i < start - 1 || i > end) {
                listElement.state = "noneSelected"
            }
        }
    }

    delegate: Item {       // must set own delegate
        id: delegateContainer
        height: delegateText.height
        width: ListView.view.width

        property alias delegateText: delegateText
        property alias dropArea: dropArea

        Component.onCompleted: {
            // Confirms that selection follows state
            state = Qt.binding(function() { return model.state })
        }

        states: [
            State {
                name: "noneSelected"
                StateChangeScript {
                    script: {
                        delegateText.deselect()
                        dropArea.start = -1
                    }
                }
            },
            State {
                name: "someSelected"
                StateChangeScript {
                    script: {
                        if (model.selectionStart !== delegateText.selectionStart || model.selectionEnd !== delegateText.selectionEnd) {
                            delegateText.select(model.selectionStart, model.selectionEnd);
                        }
                    }
                }
            },
            State {
                name: "allSelected"
                StateChangeScript {
                    script: {
                        delegateText.selectAll()
                    }
                }
            }
        ]

        TextEdit {
            id: delegateText
            width: parent.width
            selectByMouse: false // selection determined by dragArea
            readOnly: true
            persistentSelection: true
            font.pixelSize: 12
            color: root.statusTextColor
            wrapMode: Text.WrapAnywhere

            text: { return (
                        root.showMessageIds ?
                            model.id + ": " + model.message :
                            model.message
                        )}

            onSelectedTextChanged: model.selection = selectedText
            onSelectionStartChanged: model.selectionStart = selectionStart
            onSelectionEndChanged: model.selectionEnd = selectionEnd
        }

        DropArea {
            id: dropArea
            anchors {
                fill: parent
            }
            property int start:-1
            property int end:-1

            onEntered: {
                if (index > root.indexDragStarted) {
                    start = 0
                } else if (index < root.indexDragStarted){
                    start = delegateText.length
                }

                model.state = "someSelected"
                root.selectInBetween(index)
            }

            onPositionChanged: {
                end = delegateText.positionAt(drag.x, drag.y)
                delegateText.select(start, end)
            }
        }

        Connections {
            target: root
            onSelectInBetween:{
                // covers case where drag hasn't triggered before leaving first delegate
                if (index === root.indexDragStarted) {
                    if (indexDragEnded > indexDragStarted) {
                        dropArea.end = delegateText.length
                        delegateText.select(dropArea.start, dropArea.end)
                    } else if (indexDragEnded < indexDragStarted) {
                        dropArea.end = 0
                        delegateText.select(dropArea.start, dropArea.end)
                    }
                }
            }
        }

        function startSelection(mouse) {
            root.indexDragStarted = index
            model.state = "someSelected"
            var composedY = -(delegateContainer.y - mouse.y - delegateContainer.ListView.view.contentY) - delegateText.y
            var composedX = mouse.x - delegateText.x
            dropArea.start = delegateText.positionAt(composedX, composedY)
        }
    }

    Connections {
        target: listViewMouse
        onPressed: {
            root.deselectAll()
            var clickedDelegate = listView.itemAt(mouse.x+listView.contentX, mouse.y+listView.contentY)
            if (clickedDelegate) {
                clickedDelegate.startSelection(mouse)
            } else {
                root.indexDragStarted = listView.model.count
            }
        }

        onClicked: {
            root.deselectAll()
        }

        onPositionChanged: {
            if (listViewMouse.pressed) {
                if (mouse.y > listViewMouse.height * .95) {
                    listView.flick(0, -200)
                } else if (mouse.y < listViewMouse.height * .05) {
                    listView.flick(0, 200)
                }
            }
        }
    }

    Item {
        id: dragitem
        x: listViewMouse.mouseX
        y: listViewMouse.mouseY
        width: 1
        height: 1
        Drag.active: listViewMouse.drag.active
        Component.onCompleted: dragitem.parent = listViewMouse
    }

    // Overriding copy/filter functions

    function onFilter(listElement) {
        if (listElement.state !== "noneSelected") {
            listElement.state = "noneSelected"
        }
    }

    function copySelectionTest(index) {
        return listView.model.get(index).state !== "noneSelected"
    }
}
