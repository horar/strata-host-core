.pragma library

var window
var helpObjects = []
var helpView
var tourCount = 0

function registerTarget(helpTarget, targetDescription, index, viewTab) {
    var component = Qt.createComponent("qrc:/statusbar-partial-views/SGPeekThroughOverlay.qml");
    var object = component.createObject(window);

    object.index = index
    object.description = targetDescription
    // object.view = viewTab

    var helpObject = { "view": viewTab, "index": index, "target": helpTarget, "description": targetDescription, "helpObject": object }
    helpObjects.push(helpObject)
}

function registerWindow(windowTarget) {
    window = windowTarget
}

function refreshView (i) {
    helpObjects[i]["helpObject"].setTarget(helpObjects[i]["target"], window); // set/refresh the target sizing in case of window resize
}

function next(currentIndex) {
    for (var i = 0; i < helpObjects.length; i++){
        if (helpObjects[i]["index"] === currentIndex && helpView === helpObjects[i]["view"]) {
            helpObjects[i]["helpObject"].visible = false
        } else if (helpObjects[i]["index"] === currentIndex+1 && helpView === helpObjects[i]["view"]) {
            refreshView(i)
            helpObjects[i]["helpObject"].visible = true
        }
    }
}

function prev(currentIndex) {
    if (currentIndex > 0) {
        for (var i = 0; i < helpObjects.length; i++){
            if (helpObjects[i]["index"] === currentIndex && helpView === helpObjects[i]["view"]) {
                helpObjects[i]["helpObject"].visible = false
            } else if (helpObjects[i]["index"] === currentIndex-1 && helpView === helpObjects[i]["view"]) {
                refreshView(i)
                helpObjects[i]["helpObject"].visible = true
            }
        }
    }
}

function startHelpTour(viewTab) {
    helpView = viewTab
    var max = 0
    var startIndex
    for (var i = 0; i < helpObjects.length; i++){
        if (helpObjects[i]["index"] === 0 && helpObjects[i]["view"] === viewTab ) {
            startIndex = i
        }
        if(helpObjects[i]["view"] === viewTab) {
            if(helpObjects[i]["index"] > max) {
                max = helpObjects[i]["index"]
            }
        }
    }
    tourCount = max + 1
    refreshView(startIndex)
    helpObjects[startIndex]["helpObject"].visible = true
}

function reset(viewTab) {

    for (var i=0; i<helpObjects.length; i++) {
        if(helpObjects[i]["view"] === viewTab) {
           helpObjects[i]["helpObject"].destroy()
        }
    }

}
