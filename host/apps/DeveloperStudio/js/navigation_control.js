.pragma library
.import QtQuick 2.0 as QtQuickModule
.import "uuid_map.js" as UuidMap

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
    LOGIN_STATE: 2,         // User needs to login
    CONTROL_STATE: 3,       // Platform is connected and we are ready for control
}

/*
    All events to handle by navigation state machine
*/
var events = {
    PROMPT_LOGIN_EVENT:             1,
    LOGIN_SUCCESSFUL_EVENT:         2,
    LOGOUT_EVENT:                   3,
    PLATFORM_DISCONNECTED_EVENT:    4,
    VIEW_COLLATERAL_EVENT:          6,
    PLATFORM_CONNECTED_EVENT:       7,
    CLOSE_PLATFORM_VIEW_EVENT:      8,
    SWITCH_VIEW_EVENT:              9,
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
var stack_container_= null

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
    updateState(events.PROMPT_LOGIN_EVENT)
}

/*
    Retrieve the qml file in the templated file structure
*/
var PREFIX = "qrc:/views/"
function getQMLFile(class_id, filename) {

    // eventually dirname should === class_id and this UUIDmap will be unnecessary
    var dir_name = UuidMap.uuid_map[class_id]
    //console.log(LoggerModule.Logger.devStudioNavigationControlCategory, class_id + "-" + filename + "qml file requested.")

    // Build the file name - ./view/<class_id>/filename.qml
    if (filename.search(".qml") < 0){
        //console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "adding extension to filename: ", filename)
        filename = filename + ".qml"
    }

    var qml_file_name = PREFIX + dir_name + "/" + filename
    console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Locating at ", qml_file_name)

    loadViewVersion(PREFIX + dir_name)

    return qml_file_name
}

/*
   Load version.json from view and log module version
*/
function loadViewVersion(filePath)
{
    var request = new XMLHttpRequest();
    var version_file_name = filePath + "/version.json"
    console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "view version file: " + version_file_name)
    request.open("GET", version_file_name);
    request.onreadystatechange = function onVersionRequestFinished() {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status !== 200) {
                console.error(LoggerModule.Logger.devStudioNavigationControlCategory, "can't load version info: " + request.statusText + " [" + request.status + "]")
                return
            }
            var response = JSON.parse(request.responseText)
            var versionString = response.version ? response.version : "??"
            console.info(LoggerModule.Logger.devStudioNavigationControlCategory, "Loaded '" + filePath + "' in version " + versionString)
        }
    }
    request.send();
    console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "view version request sent")
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

    var component = Qt.createComponent(name, QtQuickModule.Component.PreferSynchronous, parent);
    if (component.status === QtQuickModule.Component.Error) {
        console.error(LoggerModule.Logger.devStudioNavigationControlCategory, "Cannot createComponent():", component.errorString(), "parameters:", JSON.stringify(context));
        context.error_message = component.errorString()
        return null
    }

    var object = component.createObject(parent,context)
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
            case events.PLATFORM_CONNECTED_EVENT:
                console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Platform connected, class_id:", data.class_id)
                // Don't connect if a platform view already open (only one allowed at this time)
                if (platform_view_model_.count === 0) {
                    platform_view_model_.append({"class_id":data.class_id, "view":"control", "connected":true, "name":data.name})
                    stack_container_.currentIndex = platform_view_model_.count
                } else {
                    if (platform_view_model_.get(0).class_id === data.class_id) {
                        // if existing view matches connected platform, re-connect status
                        platform_view_model_.get(0).connected = true
                    }
                }
                break;

            case events.PLATFORM_DISCONNECTED_EVENT:
                console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Platform disconnected, class_id:", data.class_id)
                // Disable control view in any matching open platform view
                for (let i=0; i< platform_view_model_.count; i++) {
                    if (platform_view_model_.get(i).class_id === data.class_id) {
                        platform_view_model_.get(i).connected = false
                        break
                    }
                }
                break;

            case events.CLOSE_PLATFORM_VIEW_EVENT:
                stack_container_.currentIndex = 0 // focus platform selector in stack_container_
                for (let i=0; i< platform_view_model_.count; i++) {
                    if (platform_view_model_.get(i).class_id === data.class_id) {
                        platform_view_model_.remove(i)
                        break
                    }
                }
                break;

            case events.VIEW_COLLATERAL_EVENT:
                // Collateral mode disables control view
                console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Entering collateral viewing mode for ", data.class_id)
                platform_view_model_.append({"class_id":data.class_id, "view":"collateral", "connected":false, "name":data.name})
                stack_container_.currentIndex = platform_view_model_.count // focus on new view in stack_container_ (offset by 1 due to platform selector occupying index 0)
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
