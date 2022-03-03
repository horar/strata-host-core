/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import tech.strata.sgwidgets 1.0

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
            var mousedItem = root.model.get(root.filterModel.mapIndexToSource(mousedItemIndex))
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
        for (var i = 0; i<root.model.count; i++) {
            root.model.get(i).selected = false;
        }
    }

    function resetStateChanged() {
        for (var i = 0; i<root.model.count; i++) {
            root.model.get(i).stateChanged = false;
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
