import QtQuick 2.12
import tech.strata.sgwidgets 1.0
import QtQml 2.12

LayoutContainer {
    id: layoutSGStatusLogBox

    property alias title: statusLogBoxObject.title
    property alias titleTextColor: statusLogBoxObject.titleTextColor
    property alias titleBoxColor:  statusLogBoxObject.titleBoxColor
    property alias titleBoxBorderColor: statusLogBoxObject.titleBoxBorderColor
    property alias statusTextColor: statusLogBoxObject.statusTextColor
    property alias statusBoxColor: statusLogBoxObject.statusBoxColor
    property alias statusBoxBorderColor: statusLogBoxObject.statusBoxBorderColor
    property alias showMessageIds: statusLogBoxObject.showMessageIds
    property alias model: statusLogBoxObject.model
    property alias filterRole: statusLogBoxObject.filterRole
    property alias copyRole: statusLogBoxObject.copyRole
    property alias fontSizeMultiplier: statusLogBoxObject.fontSizeMultiplier
    property alias scrollToEnd: statusLogBoxObject.scrollToEnd
    property alias listView: statusLogBoxObject.listView
    property alias listViewMouse: statusLogBoxObject.listViewMouse
    property alias delegate: statusLogBoxObject.delegate
    property alias filterEnabled: statusLogBoxObject.filterEnabled
    property alias copyEnabled: statusLogBoxObject.copyEnabled
    property alias filterModel: statusLogBoxObject.filterModel
    property alias listElementTemplate: statusLogBoxObject.listElementTemplate

    function append(message) {
        return statusLogBoxObject.append(message)
    }

    function remove(id) {
        return statusLogBoxObject.remove(id)
    }

    function updateMessageAtID(message, id) {
        return statusLogBoxObject.updateMessageAtID(message, id)
    }

    function clear() {
        statusLogBoxObject.clear()
    }

    function onFilter(listElement) { }

    function copySelectionTest(index) {
        return false
    }

    contentItem: SGStatusLogBox {
        id: statusLogBoxObject

        function onFilter(listElement) {
            return layoutSGStatusLogBox.onFilter(listElement)
        }

        function copySelectionTest(index) {
            return layoutSGStatusLogBox.copySelectionTest(index)
        }
    }
}
