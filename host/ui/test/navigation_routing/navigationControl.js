.pragma library
.import QtQuick 2.0 as QtQuickModule

/*
    Data that will likely be needed for platform views
*/
var context = {
    "control_qml" : "",
    "user_id" : "",
    "platform_name" : "",
    "is_logged_in" : "false",
    "platform_state" : ""
}
/*
  Mapping of verbose_name to file directory structure.
*/

//var control_page_map = {
//    "USB-PD Control": "usbControl.qml",
//    "BuBu Interface": "bubuControl.qml",
//    "USB-PD Advanced Control":"usbAdvanced.qml"
//}

var screens = {
    LOGIN_SCREEN: "SGLoginScreen.qml",
    DETECTING_PLATFORM_SCREEN : "SGDetectingPlatform.qml",
}

/*
  All states handled by navigation_state
*/
var states = {

    UNINITIALIZED: 1,
    LOGIN_STATE: 2,
    CONTROL_STATE: 3,
}

/*
    All events to handle by navigation state machine
*/
var events = {
    PROMPT_LOGIN_EVENT: 1,
    LOGIN_SUCCESSFUL_EVENT: 2,
    LOGOUT_EVENT: 3,
    PLATFORM_CONNECTED_EVENT: 4,
    PLATFORM_DISCONNECTED_EVENT: 5,
    SHOW_CONTROL_EVENT: 6,
}

/*
 Navigation Members
*/
var navigation_state = states.UNINITIALIZED
var parent_ = null

/*
    Retrieve the qml file in the templated file structure
*/
var PREFIX = "qrc:/views/"
function getQMLFile(platform_name, filename) {
    console.log(platform_name, "-", filename, "qml file requested.")

    // Build the file name - ./view/<platform_name>/filename.qml
    if (filename.search(".qml") < 0){
        console.log("adding extension to filename: ", filename)
        filename = filename + ".qml"
    }

    var qml_file_name = PREFIX + platform_name + "/" + filename
    console.log("Locating at ", qml_file_name)

    return qml_file_name
}

/*
  Navigation must be initialized with parent container
  that will hold control views
*/
function init(parent)
{
    parent_ = parent
    updateState(events.PROMPT_LOGIN_EVENT)
}
/*
  Dynamically load qml controls by qml filename
*/
function createView(name) {
    console.log("createObject: name =", name, ", parameters =", JSON.stringify(context))

    var component = Qt.createComponent(name, QtQuickModule.Component.PreferSynchronous, parent_);

    if (component.status === QtQuickModule.Component.Error) {
        console.log("ERROR: Cannot createComponent(", name, "), parameters=", JSON.stringify(context));
    }

    // TODO[Abe]: store this globally for later destroying
    var object = component.createObject(parent_,context)
    if (object === null) {
        console.log("Error creating object: name=", name, ", parameters=", JSON.stringify(context));
    }

    return object;
}

/*
  a catch-all for events that are required to be handled regardless of state
*/
function globalState(event,data)
{

    switch(event)
    {
    case events.PROMPT_LOGIN_EVENT:
        console.log("Updated state to Login:", states.LOGIN_STATE)
        navigation_state = states.LOGIN_STATE
        createView(screens.LOGIN_SCREEN)
        break;

    case events.LOGOUT_EVENT:
        // Show Login Screen
        console.log("Logging user out. Displaying Login screen")
        updateState(events.PROMPT_LOGIN_EVENT)
        break;

    case events.PLATFORM_CONNECTED_EVENT:
        // Cache platform name until we are ready to view
        console.log("Platform connected. Caching platform: ", data.platform_name)
        context.platform_name = data.platform_name
        context.platform_state = true;
        break;

    case events.PLATFORM_DISCONNECTED_EVENT:
        // Erase platform name
        console.log("Platform disconnected")
        context.platform_name = ""
        context.platform_state = false;
        break;
    default:
        console.log("Unhandled signal, ", event, " in state ", navigation_state)
        break;
    }
}

/*
  Navigator state machine
*/
function updateState(event)
{
    updateState(event,null)
}

function updateState(event, data)
{
    console.log("Received event: ", event)

    switch(navigation_state){
        case states.UNINITIALIZED:
            switch(event)
            {

            default:
                globalState(event,data)
            break;
            }

        break;

        case states.LOGIN_STATE:
            switch(event)
            {
            case events.LOGIN_SUCCESSFUL_EVENT:
                context.is_logged_in = true;
                navigation_state = states.CONTROL_STATE
                updateState(events.SHOW_CONTROL_EVENT,null)
            break;

            default:
                globalState(event,data)
            break;

            }
        break;
        case states.CONTROL_STATE:
            switch(event)
            {
            case events.SHOW_CONTROL_EVENT:
                // Refresh Control View based on conditions
                if (context.platform_state){
                    var qml_name = getQMLFile(context.platform_name, "Control")
                    createView(qml_name)
                }
                else {
                    // Disconnected; Show detection page
                    createView(screens.DETECTING_PLATFORM_SCREEN)
                }

                break;

            case events.PLATFORM_CONNECTED_EVENT:
                // Cache platform name until we are ready to view
                console.log("data:", data.platform_name)
                context.platform_name = data.platform_name
                context.platform_state = true;
                // Refresh
                updateState(events.SHOW_CONTROL_EVENT)
                break;

            case events.PLATFORM_DISCONNECTED_EVENT:
                // Erase platform name
                context.platform_name = ""
                context.platform_state = false;
                // Refresh
                updateState(events.SHOW_CONTROL_EVENT)
                break;

            default:
                globalState(event,data)
            break;
            }
        break;

        default:
            globalState(event,data)
            break;

    }
}


