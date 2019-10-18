.pragma library

var openedDialogs = []

/* Dynamically creates dialog and sets destroyOnClose. */
function createDialog(parent, url, properties) {
    if (properties === undefined) {
        properties = {}
    }

    var component = Qt.createComponent(url, parent)
    if (component) {
        return createDialogFromComponent(parent, component, properties)
    }
}

function createDialogFromComponent(parent, component, properties) {
    if (properties === undefined) {
        properties = {}
    }

    properties["destroyOnClose"] = true

    return component.createObject(parent, properties)
}

function showMessageDialog(parent, type, title, text, standardButtons, callbackAccepted, callbackRejected) {
    var properties = {
        "type": type,
        "title": title,
        "text": text,
        "standardButtons": standardButtons,
    }

    var dialog = createDialog(parent, "SGMessageDialog.qml", properties)

    if (callbackAccepted) {
        dialog.accepted.connect(callbackAccepted)
    }

    if (callbackRejected) {
        dialog.rejected.connect(callbackRejected)
    }

    dialog.open()

    return dialog
}

function showConfirmationDialog(
    parent,
    title,
    text,
    acceptButtonText,
    callbackAccepted,
    rejectButtonText,
    callbackRejected,
    type) {

    var properties = {
        "title": title,
        "text": text,
        "acceptButtonText": acceptButtonText,
        "rejectButtonText": rejectButtonText,
        "type": type,
    }

    var dialog = createDialog(parent, "SGConfirmationDialog.qml", properties)

    if (callbackAccepted) {
        dialog.accepted.connect(callbackAccepted)
    }

    if (callbackRejected) {
        dialog.rejected.connect(callbackRejected)
    }

    dialog.open()

    return dialog
}

function destroyComponent(component) {
    var index;
    for (index = openedDialogs.length - 1; index >= 0 ; --index) {
        openedDialogs[index].destroy()
        if (openedDialogs[index] === component) {
            break;
        }
    }

    openedDialogs.splice(index, openedDialogs.length - index)
}

function destroyAllDialogs() {
    for (var i = openedDialogs.length - 1; i >= 0 ; --i) {
        var dialog = openedDialogs[i]
        if (Object.getOwnPropertyNames(dialog).length > 0) {
            dialog.destroy()
        }
    }

    openedDialogs = []
}
