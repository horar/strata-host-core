.pragma library

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

    var dialog = createDialog(parent, "SGMessageDialog_1_0.qml", properties)

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
    callbackRejected) {

    var properties = {
        "title": title,
        "text": text,
        "acceptButtonText": acceptButtonText,
        "rejectButtonText": rejectButtonText,
    }

    var dialog = createDialog(parent, "SGConfirmationDialog_1_0.qml", properties)

    if (callbackAccepted) {
        dialog.accepted.connect(callbackAccepted)
    }

    if (callbackRejected) {
        dialog.rejected.connect(callbackRejected)
    }

    dialog.open()

    return dialog
}
