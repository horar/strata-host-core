.pragma library

var window
var helpObjects = []
var helpRunning = false
var helpIndex
var helpView
var tourCount = 0

/*******
   Including help library:
        import "qrc:/js/help_layout_manager.js" as Help

   Adding into the help tutorial API:
        Help.registerTarget(Target, Description, Index Number, Help View Target)
   Example: Help.registerTarget(startButton, "this button starts the motor", 0, "motorVortexHelp")

   Starting the tutorial when help icon is clicked API:
        Help.startHelpTour(Help View Target)
   Example:  Help.startHelpTour("motorVortexHelp")
*******/

function registerTarget(helpTarget, targetDescription, index, view) {
    var component = Qt.createComponent("qrc:/statusbar-partial-views/SGPeekThroughOverlay.qml");
    var object = component.createObject(window);

    object.index = index
    object.description = targetDescription

    var helpObject = { "view": view, "index": index, "target": helpTarget, "description": targetDescription, "helpObject": object }
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
        if (helpObjects[i]["index"] === currentIndex && helpView === helpObjects[i]["view"]) {
            helpObjects[i]["helpObject"].visible = false
            if (helpObjects[i]["index"] === helpObjects.length - 1) { //if last, end tour
                helpRunning = false
                break
            }
        } else if (helpObjects[i]["index"] === currentIndex+1 && helpView === helpObjects[i]["view"]) {
            refreshView(i)
            helpObjects[i]["helpObject"].visible = true
            helpIndex = i
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
                helpIndex = i
            }
        }
    }
}

function startHelpTour(view) {
    helpView = view
    var max = 0

    for (var i = 0; i < helpObjects.length; i++){

        if (helpObjects[i]["index"] === 0 && helpObjects[i]["view"] === view ) {
            helpRunning = true
            helpIndex = i
        }

        if(helpObjects[i]["view"] === view) {
            if(helpObjects[i]["index"] > max) {
                max = helpObjects[i]["index"]  // find the maximum index in this view, which is its tourCount-1
            }
        }
    }

    tourCount = max + 1
    // tourCount must be calculated before tour start so that the x/y tour counter is initialized properly
    refreshView(helpIndex)
    helpObjects[helpIndex]["helpObject"].visible = true
}

function closeTour() {
    helpObjects[helpIndex]["helpObject"].visible = false
    helpRunning = false
}

function reset(view) {
    var toDelete = [] // create array of indexes in helpObjects that need to be removed
    for (var i=0; i<helpObjects.length; i++) {
        if(helpObjects[i]["view"] === view) {
            helpObjects[i]["helpObject"].destroy()
            toDelete.push(i) // add object index to be removed from helpObjects array
        }
    }
    // remove these objects in reverse order so that the indexes aren't changed by the removal of others
    for (var j=toDelete.length-1; j>-1; j--) {
        helpObjects.splice(toDelete[j],1)
    }
}
