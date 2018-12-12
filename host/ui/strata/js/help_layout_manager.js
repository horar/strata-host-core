.pragma library

var window
var helpObjects = []
var helpRunning = false
var helpIndex

function registerTarget(helpTarget, targetDescription, index) {
    var component = Qt.createComponent("qrc:/statusbar-partial-views/SGPeekThroughOverlay.qml");
    var object = component.createObject(window);

    object.index = index
    object.description = targetDescription

    var helpObject = { "index": index, "target": helpTarget, "description": targetDescription, "helpObject": object}
    helpObjects.push(helpObject)
}

function registerWindow(windowTarget) {
    window = windowTarget.contentItem
    windowTarget.widthChanged.connect(liveResize)
    windowTarget.heightChanged.connect(liveResize)
}

function refreshView (i) {
    helpObjects[i]["helpObject"].setTarget(helpObjects[i]["target"], window); // set the target sizing on load
}

function liveResize() {
    if (helpRunning) {
        helpObjects[helpIndex]["helpObject"].setTarget(helpObjects[helpIndex]["target"], window); // refresh the target sizing on window resize
    }
}

function next(currentIndex) {
    for (var i = 0; i < helpObjects.length; i++){
        if (helpObjects[i]["index"] === currentIndex) {
            helpObjects[i]["helpObject"].visible = false
            if (helpObjects[i]["index"] === helpObjects.length - 1) { //if last, end tour
                helpRunning = false
                break
            }
        } else if (helpObjects[i]["index"] === currentIndex+1) {
            refreshView(i)
            helpObjects[i]["helpObject"].visible = true
            helpIndex = i
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
                helpIndex = i
            }
        }
    }
}

function startHelpTour() {
    for (var i = 0; i < helpObjects.length; i++){
        if (helpObjects[i]["index"] === 0) {
            refreshView(i)
            helpObjects[i]["helpObject"].visible = true
            helpRunning = true
            helpIndex = i
        }
    }
}

function closeTour() {
    for (var i = 0; i < helpObjects.length; i++){
        helpObjects[i]["helpObject"].visible = false
        helpRunning = false
    }
}

function reset() {
    for (var i=0; i<helpObjects.length; i++) {
        helpObjects[i]["helpObject"].destroy()
    }
    helpObjects = []
}
