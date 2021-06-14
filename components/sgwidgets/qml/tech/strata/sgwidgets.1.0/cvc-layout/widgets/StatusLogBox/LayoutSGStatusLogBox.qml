import QtQuick 2.12
import tech.strata.sgwidgets 1.0
import QtQml 2.12

LayoutContainer {

    property alias title: statusLogBoxObject.title
    property alias titleTextColor: statusLogBoxObject.titleTextColor
    property alias titleBoxColor:  statusLogBoxObject.titleBoxColor
    property alias titleBoxBorderColor: statusLogBoxObject.titleBoxBorderColor
    property alias statusTextColor: statusLogBoxObject.statusTextColor
    property alias statusBoxColor: statusLogBoxObject.statusBoxColor
    property alias statusBoxBorderColor: statusLogBoxObject.statusBoxBorderColor
    property alias showMessageIds: statusLogBoxObject.showMessageIds
    property variant model: statusLogBoxObject.model    // you may use your own model in advanced use cases, this can break the built-in model manipulation functions
    property alias filterRole: statusLogBoxObject.filterRole       // this role is what is cmd/ctrl-f filters on
    property alias copyRole: statusLogBoxObject.copyRole
    property alias fontSizeMultiplier: statusLogBoxObject.fontSizeMultiplier
    property alias scrollToEnd: statusLogBoxObject.scrollToEnd

    property alias listView: statusLogBoxObject.listView
    property alias listViewMouse: statusLogBoxObject.listViewMouse
    property alias delegate: statusLogBoxObject.delegate
    property alias filterEnabled: statusLogBoxObject.filterEnabled
    property alias copyEnabled: statusLogBoxObject.copyEnabled
    property alias filterModel: statusLogBoxObject.filterModel

    //  A listElement template that allows manipulation by id (see functions at bottom)
    //  as well as enablement of mouse element selection ability
    property var listElementTemplate: statusLogBoxObject.listElementTemplate
    function append(message) {
        statusLogBoxObject.append(message)
    }

    function remove(id) {
        statusLogBoxObject.remove(id)
    }

    function updateMessageAtID(message, id) {
        statusLogBoxObject.updateMessageAtID(message,id)
    }

    function clear() {
       statusLogBoxObject.clear()
    }

    contentItem: SGStatusLogBox {
        id: statusLogBoxObject
    }
}
