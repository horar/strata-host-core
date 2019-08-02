import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import tech.strata.sgwidgets 0.9

// StatusLogBox wrapper that allows selection of delegates and can copy their contents

SGStatusLogBox {
    id: root

    filterRole: "message"   // this role is what is cmd/ctrl-f filters on
    copyRole: "message"     // this role is what is copied from selected/copied ListElements

    //  Overrides built-in listElementTemplate that enables mouse delegate selection ability
    listElementTemplate: {
        "message": "",
        "id": 0,
        "selected": false,          // required role for selection functionality
        "stateChanged": false       // required role for selection functionality
    }

    delegate: Rectangle {       // must set own delegate
        id: delegatecontainer
        height: delegateText.height
        width: ListView.view.width
        color: model.selected ? "#def" : "white"  // visual indicator of selected status

        Text {
            id: delegateText
            width: parent.width
            font.pixelSize: 12
            color: root.statusTextColor
            wrapMode: Text.WrapAnywhere
            text: { return (
                        root.showMessageIds ?
                            model.id + ": " + model.message :
                            model.message
                        )}
        }
    }

    // Custom element selection functionality

    Connections {
        target: listViewMouse
        onPressed: {
            listView.interactive = false

            if (!(mouse.modifiers & Qt.ShiftModifier)){
                // deselect previous selections unless shift held
                root.deselectAll()
            }

            var listY = mouse.y + listView.contentY
            root.toggleItemAtXY(mouse.x, listY)
        }

        onReleased: {
            root.resetStateChanged()
            listView.interactive = true
            root.focus = true
        }

        onPositionChanged: {
            if (listViewMouse.pressed && listViewMouse.containsMouse) {
                var listY = mouse.y + listView.contentY
                root.toggleItemAtXY(mouse.x, listY)
            }
        }
    }

    function toggleItemAtXY(x, y) {
        var mousedItemIndex = listView.indexAt(x, y)
        if (mousedItemIndex !==-1) {
            var mousedItem = listView.model.get(mousedItemIndex)
            if (!mousedItem.stateChanged) {
                if (!mousedItem.selected) {
                    mousedItem.selected = true
                    mousedItem.stateChanged = true
                } else {
                    mousedItem.selected = false
                    mousedItem.stateChanged = true
                }
            }
        }
    }

    function deselectAll() {
        for (var i = 0; i<listView.model.count; i++) {
            listView.model.get(i).selected = false;
        }
    }

    function resetStateChanged() {
        for (var i = 0; i<listView.model.count; i++) {
            listView.model.get(i).stateChanged = false;
        }
    }

    // Overriding copy/filter functions

    function copySelectionTest(index) {
        return listView.model.get(index).selected
    }

    function onFilter(listElement) {
        if (listElement.selected) {
            listElement.selected = false;
        }
    }
}
