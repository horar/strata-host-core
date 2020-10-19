.pragma library
.import QtQuick 2.0 as QtQuickModule
.import "constants.js" as Constants
.import "utilities.js" as Utility

.import tech.strata.logger 1.0 as LoggerModule

/*
    Data that will likely be needed for platform views
*/
var context = {
    "user_id" : "",
    "first_name" : "",
    "last_name" : "",
    "error_message": ""
}

/*
  Mapping of verbose_name to file directory structure.
*/
var screens = {
    SPLASH_SCREEN: "qrc:/SplashScreen.qml",
    LOGIN_SCREEN: "qrc:/SGLogin.qml",
    PLATFORM_SELECTOR : "qrc:/SGPlatformSelector.qml",
    PLATFORM_VIEW : "qrc:/partial-views/platform-view/SGPlatformView.qml",
    CONTENT_SCREEN : "qrc:/Content.qml",
    STATUS_BAR: "qrc:/SGStatusBar.qml",
    LOAD_ERROR: "qrc:/partial-views/SGLoadError.qml"
}

/*
  All states handled by navigation_state_
*/
var states = {
    UNINITIALIZED: 1,       // Init() has not been called
    NOT_CONNECTED_STATE : 2,// HCS not connected
    LOGIN_STATE: 3,         // User needs to login
    CONTROL_STATE: 4,       // Platform is connected and we are ready for control
}

/*
    All events to handle by navigation state machine
*/
var events = {
    PROMPT_LOGIN_EVENT:             1,
    LOGIN_SUCCESSFUL_EVENT:         2,
    LOGOUT_EVENT:                   3,
    PLATFORM_CONNECTED_EVENT:       4,
    PLATFORM_DISCONNECTED_EVENT:    5,
    OPEN_PLATFORM_VIEW_EVENT:       6,
    CLOSE_PLATFORM_VIEW_EVENT:      7,
    SWITCH_VIEW_EVENT:              8,
    CONNECTION_LOST_EVENT:          9,
    CONNECTION_ESTABLISHED_EVENT:   10,
    PROMPT_SPLASH_SCREEN_EVENT:     11
}

/*
 Navigation Members
*/
var navigation_state_ = states.UNINITIALIZED
var control_container_ = null
var content_container_ = null
var main_container_ = null
var status_bar_container_ = null
var platform_view_repeater_ = null
var platform_view_model_ = null
var stack_container_ = null
var platform_list = {}
var userSettings = {}

/*
  Navigation initialized with parent containers
  that will hold views
*/
function init(status_bar_container, stack_container)
{
    status_bar_container_ = status_bar_container
    main_container_ = stack_container.mainContainer
    platform_view_repeater_ = stack_container.platformViewRepeater
    platform_view_model_ = stack_container.platformViewModel
    stack_container_ = stack_container
    updateState(events.PROMPT_SPLASH_SCREEN_EVENT)
}

/*
    Retrieve the qml file in the RCC templated file structure
*/
function getQMLFile(filename, class_id, version = "") {
    // Build the file name - ./<class_id>/<version>/filename.qml

    if (filename.search(".qml") < 0){
        filename = filename + ".qml"
    }
    let prefix = "qrc:/" + (class_id === "" ? class_id : class_id + "/") + (version === "" ? version : version + "/")
    var rcc_filepath = prefix + filename;

    console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Locating at ", rcc_filepath)

    return rcc_filepath
}

/*
  Dynamically load qml controls by qml filename
*/
function createView(name, parent)
{
    //console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "createView: name =", name, ", parameters =", JSON.stringify(context))

    try {
        // Remove children from container before creating another instance
        removeView(parent)
    }
    catch(err){
        console.error(LoggerModule.Logger.devStudioNavigationControlCategory, "ERROR: Could not destroy child")
    }
        var object = Utility.createObject(name,parent,context);
    if (object === null) {
        console.error(LoggerModule.Logger.devStudioNavigationControlCategory, "Error creating object: name=", name, ", parameters=", JSON.stringify(context));
    } else {
        context.error_message = ""
    }
    return object;
}

/*
  Remove children from a container
*/
function removeView(parent)
{
    if (parent.children.length > 0){
        //console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Destroying view")
        for (var x in parent.children){
            parent.children[x].destroy()
        }
    }
}

/*
  A catch-all for events that are required to be handled for default event behaviors
  or handle events that were not caught in the main state machine handler
*/
function globalEventHandler(event,data)
{

    switch(event)
    {
    case events.PROMPT_SPLASH_SCREEN_EVENT:
        navigation_state_ = states.NOT_CONNECTED_STATE
        createView(screens.SPLASH_SCREEN, main_container_)

        // Remove StatusBar
        removeView(status_bar_container_)
        status_bar_container_.visible = false

        break;
    case events.PROMPT_LOGIN_EVENT:
        //console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Updated state to Login:", states.LOGIN_STATE)
        navigation_state_ = states.LOGIN_STATE

        // Show login, reset stack
        createView(screens.LOGIN_SCREEN, main_container_)

        // Remove StatusBar at Login
        removeView(status_bar_container_)
        status_bar_container_.visible = false
        break;

    case events.LOGOUT_EVENT:
        context.user_id = ""
        context.first_name = ""
        context.last_name = ""

        // Reset stack, remove all platform views
        stack_container_.currentIndex = 0
        while (platform_view_model_.count > 0) {
            platform_view_model_.remove(0)
        }

        // Show Login Screen
        navigation_state_ = states.LOGIN_STATE
        updateState(events.PROMPT_LOGIN_EVENT)
        break;

    case events.CONNECTION_LOST_EVENT:
        // Reset stack, remove all platform views
        stack_container_.currentIndex = 0
        while (platform_view_model_.count > 0) {
            platform_view_model_.remove(0)
        }

        updateState(events.PROMPT_SPLASH_SCREEN_EVENT)
        break;

    default:
        console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Unhandled signal, ", event, " in state ", navigation_state_)
        break;
    }
}

/*
  Navigator state machine event handler with no data
*/
function updateState(event)
{
    updateState(event,null)
}

/*
  Main state machine event handler.
  Any navigation request must use this function to attempt a navigation change.
  This includes SGXXX.qml as well as the platform specific Control/Content.qmls
  This state machine determines what is shown (or not shown) on the:
  1. Statusbar container
  2. Flipable Control container
  3. Flipable Content container
*/
function updateState(event, data)
{
    switch(navigation_state_){
        case states.UNINITIALIZED:
            switch(event)
            {

            default:
                globalEventHandler(event,data)
            break;
            }

        break;

        case states.NOT_CONNECTED_STATE:
            switch(event) {
            case events.CONNECTION_ESTABLISHED_EVENT:
                updateState(events.PROMPT_LOGIN_EVENT)
                break;
            default:
                globalEventHandler(event,data)
            break;
            }

            break;
        case states.LOGIN_STATE:
            switch(event)
            {
            case events.LOGIN_SUCCESSFUL_EVENT:
                context.user_id = data.user_id
                context.first_name = data.first_name
                context.last_name = data.last_name

                // Update StatusBar
                status_bar_container_.visible = true
                let statusBar = createView(screens.STATUS_BAR, status_bar_container_)

                createView(screens.PLATFORM_SELECTOR, main_container_)

                // Progress to next state
                navigation_state_ = states.CONTROL_STATE

                 // Populate platforms only after all UI components are complete
                statusBar.loginSuccessful()
            break;

            default:
                globalEventHandler(event,data)
            break;

            }
        break;
        case states.CONTROL_STATE:
            switch(event)
            {
            case events.OPEN_PLATFORM_VIEW_EVENT:
                console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Opening Platform View for class_id:", data.class_id, "device_id:", data.device_id)

                // If matching view exists, bring it back into focus
                for (let i = 0; i < platform_view_model_.count; i++) {
                    let open_view = platform_view_model_.get(i)
                    if (open_view.class_id === data.class_id && open_view.device_id === data.device_id) {
                        updateState(events.SWITCH_VIEW_EVENT, {"index": i+1})
                        return
                    }
                }

                platform_view_model_.append(data)

                updateState(events.SWITCH_VIEW_EVENT, {"index": platform_view_model_.count}) // focus on new view in stack_container_
                break;

            case events.PLATFORM_CONNECTED_EVENT:
                console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Platform connected, class_id:", data.class_id, "device_id:", data.device_id)

                let view_index = -1
                let connected_view

                // Find view bound to this device, set connected
                // OR if none found, find view matching class_id, bind to it, set connected
                for (let j = 0; j < platform_view_model_.count; j++) {
                    connected_view = platform_view_model_.get(j)
                    if (connected_view.class_id === data.class_id){
                        if (connected_view.device_id === data.device_id) {
                            view_index = j
                            break
                        } else if (connected_view.device_id === Constants.NULL_DEVICE_ID){
                            view_index = j
                        }
                    }
                }

                if (view_index !== -1) {
                    connected_view = platform_view_model_.get(view_index)
                    connected_view.device_id = data.device_id
                    connected_view.firmware_version = data.firmware_version
                    connected_view.connected = true

                    if (userSettings.switchToActive) {
                        updateState(events.SWITCH_VIEW_EVENT, {"index": view_index})
                    }
                }

                if (userSettings.autoOpenView) {
                    updateState(events.OPEN_PLATFORM_VIEW_EVENT, data)
                }

                break;

            case events.PLATFORM_DISCONNECTED_EVENT:
                console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Platform disconnected, class_id:", data.class_id, "device_id:", data.device_id)
                // Disconnect any matching open platform view
                for (let k = 0; k < platform_view_model_.count; k++) {
                    let disconnected_view = platform_view_model_.get(k)
                    if (disconnected_view.class_id === data.class_id && disconnected_view.device_id === data.device_id) {
                        disconnected_view.connected = false
                        disconnected_view.firmware_version = ""
                        break
                    }
                }
                break;

            case events.CLOSE_PLATFORM_VIEW_EVENT:
                let l
                for (l = 0; l < platform_view_model_.count; l++) {
                    let closed_view = platform_view_model_.get(l)
                    if (closed_view.class_id === data.class_id && closed_view.device_id === data.device_id) {
                        platform_view_model_.remove(l)
                        break
                    }
                }

                updateState(events.SWITCH_VIEW_EVENT, {"index": l}) // focus on tab to left
                break;

            case events.SWITCH_VIEW_EVENT:
                // Change index of main view stack - switch between views or between view and platform selection
                if (stack_container_.currentIndex !== data.index) {
                    stack_container_.currentIndex = data.index
                }
                break;

            default:
                globalEventHandler(event,data)
            break;
            }
        break;

        default:
            globalEventHandler(event,data)
            break;
    }
}
