/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
.pragma library
.import "navigation_control.js" as NavigationControl
.import "constants.js" as Constants
.import "utilities.js" as Utility
.import QtQuick 2.0 as QtQuickModule
.import tech.strata.logger 1.0 as LoggerModule

var window
var current_device_id
var current_tour_targets
var tour_running = false
var tour_count = 0
var internal_tour_index
var views = [ ]
var stackContainer
var control_view_creator = null
var help_object = null
var font_size_multiplier = 1

var utility = Qt.createQmlObject('import QtQuick 2.0;\
    QtObject { \
        signal internal_tour_indexChanged(int index);\
        signal tour_runningChanged(bool tour_running);\
        property string runningTourName: "";\
    }', Qt.application, 'HelpUtility');


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

function registerTarget(helpTarget, targetDescription, index, tourName) {
    // find view and tour to append target to
    let tourLocation = locateTour(current_device_id, tourName)
    if (tourLocation.tourIndex === null) {
        // create tour in view if view found, but no tour found
        tourLocation.tourIndex = createTour(tourLocation.viewIndex, tourName)
    }

    let tourTargetList = views[tourLocation.viewIndex].view_tours[tourLocation.tourIndex].tour_targets
    let tourTarget = {"index": index, "target": helpTarget, "description": targetDescription}

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

function setDeviceId(device_id) {
    // incoming target registration belongs to new device_id, needs new tour initialized
    current_device_id = device_id
    createView(device_id)
}

function createView(device_id) {
    let view = {
        "view_id": device_id,
        "view_tours" : []
    }
    views.push(view)
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

function locateTour(device_id, tourName) {
    for (let i=0; i<views.length; i++) {
        if (views[i].view_id === device_id) {
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

function startHelpTour(tourName, device_id) {
    if (device_id === undefined) {
        const platformView = NavigationControl.platform_view_model_.get(stackContainer.currentIndex-1)

        // If the current stack view is not in the platform_view_model_, indicates debug control view
        if (platformView) {
            device_id = platformView.device_id
        } else {
            if (control_view_creator) {
                device_id = control_view_creator.debugPlatform.device_id
            } else {
                console.error("Help tour started from nonstandard location")
                return
            }
        }
    }

    let tourLocation = locateTour(device_id, tourName)
    if (tourLocation.viewIndex === null || tourLocation.tourIndex === null) {
        console.error(LoggerModule.Logger.devStudioHelpCategory, "No help tour found for tour name", tourName, JSON.stringify(tourLocation))
        return
    }

    current_tour_targets = views[tourLocation.viewIndex].view_tours[tourLocation.tourIndex].tour_targets
    font_size_multiplier = views[tourLocation.viewIndex].view_tours[tourLocation.tourIndex].font_size_multiplier

    // tour_count initializes the x/y tour counter
    tour_count = current_tour_targets.length
    tour_running = true
    utility.runningTourName = tourName
    utility.tour_runningChanged(tour_running)

    findTourStop(0)
}

function next(currentIndex) {
    if (currentIndex === tour_count - 1) { // if last, end tour
        closeTour()
        return
    }
    findTourStop(currentIndex + 1)
}

function prev(currentIndex) {
    if (currentIndex > 0) {
        findTourStop(currentIndex - 1)
    }
}

function findTourStop(index) {
    for (let i = 0; i < current_tour_targets.length; i++){
        if (current_tour_targets[i]["index"] === index) {
            createHelpObject(current_tour_targets[i])
            internal_tour_index = i
            utility.internal_tour_indexChanged(i)
            break
        }
    }
}

function closeTour() {
    if (tour_running) {
        destroyHelpObject()
        font_size_multiplier = 1
        tour_running = false
        utility.tour_runningChanged(tour_running)
        utility.runningTourName = ""
    }
}

function registerWindow(windowTarget, stackContainerTarget) {
    window = windowTarget.contentItem
    stackContainer = stackContainerTarget
}

function refreshView (i) {
    // set the target sizing on load
    if (help_object) {
        help_object.setTarget(current_tour_targets[i]["target"])
    }
}

function destroyHelp() {
    // called on strata destruction & logout, remove all dynamically created objects
    views = []
    destroyHelpObject()
    current_device_id = Constants.NULL_DEVICE_ID
}

function killView(index) {
    views.splice(index, 1)
}

function setTourFontSizeMultiplier(tourName, fontSizeMultiplier) {
    let tourLocation = locateTour(current_device_id, tourName)
    if (tourLocation.viewIndex === null || tourLocation.tourIndex === null) {
        console.error(LoggerModule.Logger.devStudioHelpCategory, "Tour fontSizeMultiplier not set - '" + tourName + "' tour not found")
    } else {
        views[tourLocation.viewIndex].view_tours[tourLocation.tourIndex].font_size_multiplier = fontSizeMultiplier
    }
}

function createHelpObject(tourTarget) {
    destroyHelpObject()
    help_object = Utility.createObject("qrc:/partial-views/help-tour/SGPeekThroughOverlay.qml", window)
    help_object.index = tourTarget.index
    help_object.description = tourTarget.description
    help_object.setTarget(tourTarget.target)
    if (font_size_multiplier !== 1) {
        help_object.fontSizeMultiplier = font_size_multiplier
    }
}

function destroyHelpObject() {
    if (help_object !== null) {
        help_object.destroy()
        help_object = null
    }
}

function resetDeviceIdTour (device_id) {
    // for CVC, need to clear out help tour for device id, otherwise help views are cached and won't update properly which is problematic for development
    for (let i=0; i<views.length; i++) {
        if (views[i].view_id === device_id) {
            killView(i)
            break
        }
    }
}
