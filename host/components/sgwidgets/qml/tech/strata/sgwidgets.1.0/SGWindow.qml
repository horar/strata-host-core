import QtQuick 2.12
import QtQuick.Window 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Window {
    id: window

    property bool destroyOnClose: false

    Component.onCompleted: {
        SGWidgets.SGDialogJS.openedDialogs.push(window)
    }

    onClosing: {
        close.accepted = false
        if (destroyOnClose) {
            SGWidgets.SGDialogJS.destroyComponent(window)
        }
    }
}
