.pragma library
.import "navigation_control.js" as NavigationControl
.import QtQuick 2.0 as QtQuickModule
.import tech.strata.logger 1.0 as LoggerModule

var window
var current_class_id
var current_tour_targets
var tour_running = false
var tour_count = 0
var internal_tour_index
var views = [ ]

var utility = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal internal_tour_indexChanged(int index); signal tour_runningChanged(var tour_running)  }', Qt.application, 'HelpUtility');


/*******
   Including help library:
        import "qrc:/js/help_layout_manager.js" as Help

   Adding help tour targets (stops on a help tour) in Component.onCompleted:
        Help.registerTarget(Target, "Description", Index Number, "nameOfHelpTour")
   Example:  Help.registerTarget(startButton, "This button starts the motor", 0, "motorVortexHelp")

   Setting fontSizeMultiplier after at least one target is registered to a tour:
        Help.setTourFontSizeMultiplier("nameOfHelpTour", fontSizeMultiplier)
   Example:  Help.setTourFontSizeMultiplier("motorVortexHelp", 2)

   Starting the tour when help icon is clicked:
        Help.startHelpTour("nameOfHelpTour")
   Example:  Help.startHelpTour("motorVortexHelp")
*******/

// Runs up to 2 help views: 1 for Strata, and 1 for the current plaform listed in nav_control
// Each view can run any number of help tours, assuming their names are unique to that view

function registerTarget(helpTarget, targetDescription, index, tourName) {
    var class_id

    if (NavigationControl.context.class_id === "") {
        // strata help registers before any platforms are connected
        class_id = "strataMain"
    } else {
        class_id = NavigationControl.context.class_id
    }

    var tourIndices = null;

    if (current_class_id !== class_id) {
        // incoming target registration belongs to new class_id, needs new tour initialized
        if (views.length >1) {
            // new class_id is replacing a disconnected platform (strataMain is views[0]); older help needs to be removed
            // console.log(LoggerModule.Logger.devStudioHelpCategory, "Deleting previous help", current_class_id, class_id, views.length)
            killView(1)
        }

        // console.log(LoggerModule.Logger.devStudioHelpCategory, "CREATING HELP VIEW and TOUR", class_id, tourName)
        current_class_id = class_id
        tourIndices = createView(class_id, tourName)
    } else {
        // find view and tour to append target to
        tourIndices = locateTour(class_id, tourName)
        if (tourIndices[1] === null) {
            // create tour in view if view found, but no tour found
            // console.log(LoggerModule.Logger.devStudioHelpCategory, "CREATING TOUR", tourName, "for VIEW", current_class_id)
            tourIndices[1] = createTour(tourIndices[0], tourName)
        }
    }

    var tourTargetList = views[tourIndices[0]].view_tours[tourIndices[1]].tour_targets

    var component = Qt.createComponent("qrc:/partial-views/help-tour/SGPeekThroughOverlay.qml");
    if (component.status === QtQuickModule.Component.Error) {
        console.error(LoggerModule.Logger.devStudioHelpCategory, "ERROR: Cannot createComponent ", component.errorString());
    }
    var tourStop = component.createObject(window);
    tourStop.index = index
    tourStop.description = targetDescription
    var tourTarget = {"index": index, "target": helpTarget, "description": targetDescription, "helpObject": tourStop}

    for (var i=0; i<tourTargetList.length; i++) {
        if (tourTargetList[i].index === index) {
            // update tourTarget if it already exists (occurs when same platform disconnected and reconnected - must update object references)
            tourTargetList[i] = tourTarget
            return
        }
    }

    // otherwise append as new target
    tourTargetList.push(tourTarget)
}

function createView(class_id, tourName) {
    var view = {
        "view_id": class_id,
        "view_tours" : [
            {
                "tour_name": tourName,
                "font_size_multiplier": 1,
                "tour_targets": []
            }
        ]
    }
    views.push(view)
    return [views.length-1, 0]
}

function createTour(viewNumber, tourName) {
    var tour = {
        "tour_name": tourName,
        "font_size_multiplier": 1,
        "tour_targets": []
    }
    views[viewNumber].view_tours.push(tour)
    return views[viewNumber].view_tours.length-1
}

function locateTour(class_id, tourName) {
    for (var i=0; i<views.length; i++) {
        if (views[i].view_id === class_id) {
            for (var j=0; j<views[i].view_tours.length; j++) {
                if (views[i].view_tours[j].tour_name === tourName) {
                    return [i, j]
                }
            }
            return [i, null]
        }
    }
    return [null, null]
}

function startHelpTour(tourName, class_id) {
    if (class_id !== "strataMain") {
        class_id = NavigationControl.context.class_id
    }

    var tourIndices = locateTour(class_id, tourName)
    if (tourIndices[1] === null || tourIndices[0] === null) {
        console.error(LoggerModule.Logger.devStudioHelpCategory, "No help tour found for tour name", tourName)
        return
    }

    current_tour_targets = views[tourIndices[0]].view_tours[tourIndices[1]].tour_targets
    let font_size_multiplier = views[tourIndices[0]].view_tours[tourIndices[1]].font_size_multiplier

    // tour_count initializes the x/y tour counter
    tour_count = current_tour_targets.length

    for (var i = 0; i < tour_count; i++){
        let tour_target = current_tour_targets[i]
        if (tour_target.index === 0) {
            tour_running = true
            utility.tour_runningChanged(tour_running)
            internal_tour_index = i
            utility.internal_tour_indexChanged(i)
        }
        if (font_size_multiplier !== 1) {
            tour_target.helpObject.fontSizeMultiplier = font_size_multiplier
        }
    }

    refreshView(internal_tour_index)
    current_tour_targets[internal_tour_index]["helpObject"].visible = true
}

function next(currentIndex) {
    for (var i = 0; i < current_tour_targets.length; i++){
        if (current_tour_targets[i]["index"] === currentIndex) {
            current_tour_targets[i]["helpObject"].visible = false
            if (current_tour_targets[i]["index"] === tour_count - 1) { //if last, end tour
                tour_running = false
                utility.tour_runningChanged(tour_running)

                break
            }
        } else if (current_tour_targets[i]["index"] === currentIndex+1) {
            refreshView(i)
            current_tour_targets[i]["helpObject"].visible = true
            internal_tour_index = i
            utility.internal_tour_indexChanged(i)
        }
    }
}

function prev(currentIndex) {
    if (currentIndex > 0) {
        for (var i = 0; i < current_tour_targets.length; i++){
            if (current_tour_targets[i]["index"] === currentIndex) {
                current_tour_targets[i]["helpObject"].visible = false
            } else if (current_tour_targets[i]["index"] === currentIndex-1) {
                refreshView(i)
                current_tour_targets[i]["helpObject"].visible = true
                internal_tour_index = i
                utility.internal_tour_indexChanged(i)
            }
        }
    }
}

function closeTour() {
    if (tour_running) {
        current_tour_targets[internal_tour_index]["helpObject"].visible = false
        tour_running = false
    }
    utility.tour_runningChanged(tour_running)
}

function registerWindow(windowTarget) {
    window = windowTarget.contentItem
    windowTarget.widthChanged.connect(liveResize)
    windowTarget.heightChanged.connect(liveResize)
}

function refreshView (i) {
    // set the target sizing on load
    current_tour_targets[i]["helpObject"].setTarget(current_tour_targets[i]["target"], window);
}

function liveResize() {
    // refresh the target sizing on window resize
    if (tour_running) {
        refreshView(internal_tour_index)
    }
}

function destroyHelp() {
    // only called on strata destruction, remove all dynamically created objects
    for (var i=views.length-1; i>=0; i--) {
        killView(i)
    }
    current_class_id = ""
}

function killView(index) {
    for (var i=0; i<views[index].view_tours.length; i++) {
        //        console.log(LoggerModule.Logger.devStudioHelpCategory, "Destroying", views[index].view_tours[i].tour_name)
        for (var j=0; j<views[index].view_tours[i].tour_targets.length; j++) {
            views[index].view_tours[i].tour_targets[j].helpObject.destroy()
        }
    }
    views.pop()
}

function setTourFontSizeMultiplier(tourName, fontSizeMultiplier) {
    let tourIndices = locateTour(NavigationControl.context.class_id, tourName)
    if (tourIndices[1] === null || tourIndices[0] === null) {
        console.error(LoggerModule.Logger.devStudioHelpCategory, "Tour fontSizeMultiplier not set - '" + tourName + "' tour not found")
    } else {
        views[tourIndices[0]].view_tours[tourIndices[1]].font_size_multiplier = fontSizeMultiplier
    }
}
