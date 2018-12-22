.pragma library

var window
var helpObjects = []
var helpView
var tourCount = 0


/*******
   Adding into the help tutorial API:
   Help.registerTarget(Target, Description, Index Number, View Target)
   Example: Help.registerTarget(startButton "this button starts the motor", 0, "motorVortexHelp")

   Starting the tutorial when help icon is clicked API:
   Help.startHelpTour(view Target)
   Example:  Help.startHelpTour("motorVortexHelp")
*******/

function registerTarget(helpTarget, targetDescription, index, viewTab) {

    var component = Qt.createComponent("qrc:/statusbar-partial-views/SGPeekThroughOverlay.qml");
    var object = component.createObject(window);

    object.index = index
    object.description = targetDescription

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
                max = helpObjects[i]["index"]  // find the maximum index in this view, which is its tourCount-1
            }
        }
    }

    tourCount = max + 1
    refreshView(startIndex)
    helpObjects[startIndex]["helpObject"].visible = true
}


function reset(viewTab) {

    var toDelete = [] // create array of indexes in helpObjects that need to be removed

    for (var i=0; i<helpObjects.length; i++) {
        if(helpObjects[i]["view"] === viewTab) {
            helpObjects[i]["helpObject"].destroy()
            toDelete.push(i) // add object index to be removed from helpObjects array
        }
    }

    // remove these objects in reverse order so that the indexes aren't changed by the removal of others
    for (var j=toDelete.length-1; j>-1; j--) {
        helpObjects.splice(toDelete[j],1)
    }
}
