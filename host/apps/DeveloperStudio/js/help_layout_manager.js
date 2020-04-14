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

var utility = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal internal_tour_indexChanged(int index); signal tour_runningChanged(bool tour_running)}', Qt.application, 'HelpUtility');


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
    // find view and tour to append target to
    let tourLocation = locateTour(current_class_id, tourName)
    if (tourLocation.tourIndex === null) {
        // create tour in view if view found, but no tour found
        tourLocation.tourIndex = createTour(tourLocation.viewIndex, tourName)
    }

    let tourTargetList = views[tourLocation.viewIndex].view_tours[tourLocation.tourIndex].tour_targets

    let component = Qt.createComponent("qrc:/partial-views/help-tour/SGPeekThroughOverlay.qml");
    if (component.status === QtQuickModule.Component.Error) {
        console.error(LoggerModule.Logger.devStudioHelpCategory, "ERROR: Cannot createComponent ", component.errorString());
    }
    let tourStop = component.createObject(window);
    tourStop.index = index
    tourStop.description = targetDescription
    let tourTarget = {"index": index, "target": helpTarget, "description": targetDescription, "helpObject": tourStop}

    for (let i=0; i<tourTargetList.length; i++) {
        if (tourTargetList[i].index === index) {
            // update tourTarget if it already exists (occurs when same platform disconnected and reconnected - must update object references)
            tourTargetList[i] = tourTarget
            return
        }
    }

    // otherwise append as new target
    tourTargetList.push(tourTarget)
}

function setClassId(class_id) {
    // incoming target registration belongs to new class_id, needs new tour initialized
    if (views.length >1) {
        // new class_id is replacing a disconnected platform (strataMain is views[0]); older help needs to be removed
        killView(1)
    }

    current_class_id = class_id
    createView(class_id)
}

function createView(class_id ) {
    let view = {
        "view_id": class_id,
        "view_tours" : []
    }
    views.push(view)
    return [views.length-1, 0]
}

function createTour(viewIndex, tourName) {
    let tour = {
        "tour_name": tourName,
        "font_size_multiplier": 1,
        "tour_targets": []
    }
    views[viewIndex].view_tours.push(tour)
    return views[viewIndex].view_tours.length-1
}

function locateTour(class_id, tourName) {
    for (let i=0; i<views.length; i++) {
        if (views[i].view_id === class_id) {
            for (let j=0; j<views[i].view_tours.length; j++) {
                if (views[i].view_tours[j].tour_name === tourName) {
                    return {"viewIndex":i, "tourIndex": j}
                }
            }
            return {"viewIndex":i, "tourIndex": null}
        }
    }
    return {"viewIndex":null, "tourIndex": null}
}

function startHelpTour(tourName, class_id) {
    if (class_id !== "strataMain") {
        class_id = current_class_id
    }

    let tourLocation = locateTour(class_id, tourName)
    if (tourLocation.viewIndex === null || tourLocation.tourIndex === null) {
        console.error(LoggerModule.Logger.devStudioHelpCategory, "No help tour found for tour name", tourName, JSON.stringify(tourLocation))
        return
    }

    current_tour_targets = views[tourLocation.viewIndex].view_tours[tourLocation.tourIndex].tour_targets
    let font_size_multiplier = views[tourLocation.viewIndex].view_tours[tourLocation.tourIndex].font_size_multiplier

    // tour_count initializes the x/y tour counter
    tour_count = current_tour_targets.length

    for (let i = 0; i < tour_count; i++){
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
    for (let i = 0; i < current_tour_targets.length; i++){
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
        for (let i = 0; i < current_tour_targets.length; i++){
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
    // called on strata destruction & logout, remove all dynamically created objects
    for (let i=views.length-1; i>=0; i--) {
        killView(i)
    }
    current_class_id = ""
}

function killView(index) {
    for (let i=0; i<views[index].view_tours.length; i++) {
        //        console.log(LoggerModule.Logger.devStudioHelpCategory, "Destroying", views[index].view_tours[i].tour_name)
        for (let j=0; j<views[index].view_tours[i].tour_targets.length; j++) {
            views[index].view_tours[i].tour_targets[j].helpObject.destroy()
        }
    }
    views.splice(index, 1)
}

function setTourFontSizeMultiplier(tourName, fontSizeMultiplier) {
    let tourLocation = locateTour(current_class_id, tourName)
    if (tourLocation.viewIndex === null || tourLocation.tourIndex === null) {
        console.error(LoggerModule.Logger.devStudioHelpCategory, "Tour fontSizeMultiplier not set - '" + tourName + "' tour not found")
    } else {
        views[tourLocation.viewIndex].view_tours[tourLocation.tourIndex].font_size_multiplier = fontSizeMultiplier
    }
}
