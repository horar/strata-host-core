.pragma library

var window
var helpObjects = []

function registerTarget(helpTarget, targetDescription, index) {
    var component = Qt.createComponent("qrc:/statusbar-partial-views/SGPeekThroughOverlay.qml");
    var object = component.createObject(window);

    object.index = index
    object.description = targetDescription

    var helpObject = { "index": index, "target": helpTarget, "description": targetDescription, "helpObject": object}
    helpObjects.push(helpObject)
}

function registerWindow(windowTarget) {
    window = windowTarget
}

function refreshHelp () {
    for (var i = 0; i < helpObjects.length; i++){
        if (helpObjects[i]["helpObject"].visible) {
            helpObjects[i]["helpObject"].setTarget(helpObjects[i]["target"], window);
        }
    }
}

function refreshView (i) {
    helpObjects[i]["helpObject"].setTarget(helpObjects[i]["target"], window); // set/refresh the target sizing in case of window resize
}

function next(currentIndex) {
    for (var i = 0; i < helpObjects.length; i++){
        if (helpObjects[i]["index"] === currentIndex) {
            helpObjects[i]["helpObject"].visible = false
        } else if (helpObjects[i]["index"] === currentIndex+1) {
            refreshView(i)
            helpObjects[i]["helpObject"].visible = true
        }
    }
}

function prev(currentIndex) {
    if (currentIndex > 0) {
        for (var i = 0; i < helpObjects.length; i++){
            if (helpObjects[i]["index"] === currentIndex) {
                helpObjects[i]["helpObject"].visible = false
            } else if (helpObjects[i]["index"] === currentIndex-1) {
                refreshView(i)
                helpObjects[i]["helpObject"].visible = true
            }
        }
    }
}

function startHelpTour() {
    for (var i = 0; i < helpObjects.length; i++){
        if (helpObjects[i]["index"] === 0) {
            refreshView(i)
            helpObjects[i]["helpObject"].visible = true
        }
    }
}

function reset() {
    for (var i=0; i<helpObjects.length; i++) {
        helpObjects[i]["helpObject"].destroy()
    }
    helpObjects = []
}
