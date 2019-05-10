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

    var obj = component.createObject(parent, properties)
    var pos = centreObject(obj, parent)

    obj.x = pos.x
    obj.y = pos.y

    return obj
}

function showMessageDialog(parent, type, title, text, standardButtons, callbackAccepted, callbackRejected) {
    var properties = {
        "type": type,
        "title": title,
        "text": text,
        "standardButtons": standardButtons,
    }

    var dialog = createDialog(parent, "SgMessageDialog.qml", properties)

    if (callbackAccepted) {
        dialog.accepted.connect(callbackAccepted)
    }

    if (callbackRejected) {
        dialog.rejected.connect(callbackRejected)
    }

    dialog.open()
}

function centreObject(object, parent) {
    var pos = {}

    pos["x"] = Math.round((parent.width - object.width) / 2)
    pos["y"] = Math.round((parent.height - object.height) / 2)

    return pos
}

function generateHtmlUnorderedList(list) {
    var text = "<ul>"
    for (var i = 0; i < list.length; ++i) {
        text += "<li>" + list[i] + "</li>"
    }
    text += "</ul>"

    return text
}
