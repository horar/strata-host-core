.pragma library
.import QtQuick 2.0 as QtQuickModule
.import "metrics.js" as Metrics
.import "uuid_map.js" as UuidMap

.import tech.strata.logger 1.0 as LoggerModule

/*
    Data that will likely be needed for platform views
*/
var context = {
    "user_id" : "",
    "class_id" : "",
    "is_logged_in" : false,
    "platform_state" : ""
}

/*
  Mapping of verbose_name to file directory structure.
*/
var screens = {
    LOGIN_SCREEN: "qrc:/SGLoginScreen.qml",
    WELCOME_SCREEN : "qrc:/SGWelcome.qml",
    CONTENT_SCREEN : "qrc:/Content.qml",
    STATUS_BAR: "qrc:/SGStatusBar.qml"
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
    SHOW_CONTROL_EVENT:             5,
    OFFLINE_MODE_EVENT:             6,
    NEW_PLATFORM_CONNECTED_EVENT:   7,
    TOGGLE_CONTROL_CONTENT:         8,
    SHOW_CONTROL:                   9,
    SHOW_CONTENT:                   10,
}

/*
 Navigation Members
*/
var navigation_state_ = states.UNINITIALIZED
var control_container_ = null
var content_container_ = null
var status_bar_container_ = null
var flipable_parent_= null

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

    return qml_file_name
}

/*
  Navigation must be initialized with parent container
  that will hold control views
*/
function init(flipable_parent, control_parent, content_parent, bar_parent)
{
    // Create metrics object to track usage
    Metrics.init(context)

    flipable_parent_    = flipable_parent
    control_container_ = control_parent
    content_container_ = content_parent
    status_bar_container_ = bar_parent
    updateState(events.PROMPT_LOGIN_EVENT)
}

/*
  Dynamically load qml controls by qml filename
*/
function createView(name, parent)
{
    //console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "createView: name =", name, ", parameters =", JSON.stringify(context))

    var component = Qt.createComponent(name, QtQuickModule.Component.PreferSynchronous, parent);

    if (component.status === QtQuickModule.Component.Error) {
        console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "ERROR: Cannot createComponent(", name, "), parameters=", JSON.stringify(context));
        console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "errString: ", component.errorString())
    }

    /*
        In some cases we have 'indestructible' children.
        This seems to occur when a qml is being loaded and while executing tries to destroy itself.
        Having auto selection enabled on the WelcomeScreen will cause this scenario. Catch the error here
        output an error. When it errors the child will eventually get destroyed on subsequent view creation
        TODO: Modify autoselect so it doesn't try to destroy itself on load.
    */
    try {
        // Remove children from container before creating another instance
        removeView(parent)
    }
    catch(err){
        console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "ERROR: Could not destroy child")
    }

    var object = component.createObject(parent,context)
    if (object === null) {
        console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Error creating object: name=", name, ", parameters=", JSON.stringify(context));
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

        // Update both containers
        removeView(content_container_)
        createView(screens.LOGIN_SCREEN, control_container_)

        // Remove StatusBar at Login
        removeView(status_bar_container_)
        status_bar_container_.visible = false
        break;

    case events.LOGOUT_EVENT:
        updateState(events.SHOW_CONTROL)

        context.is_logged_in = false;
        context.user_id = ""

        removeView(content_container_)
        removeView(control_container_)

        // Set login state before disconnect event, so global event happens, not control_state version
        navigation_state_ = states.LOGIN_STATE
        updateState(events.PLATFORM_DISCONNECTED_EVENT)

        // Show Login Screen
//        console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Logging user out. Displaying Login screen")
        updateState(events.PROMPT_LOGIN_EVENT)
        break;

    case events.NEW_PLATFORM_CONNECTED_EVENT:
        // Cache platform name until we are ready to view
        //console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Platform connected. Caching platform: ", data.class_id)
        context.class_id = data.class_id
        context.platform_state = true;
        break;

    case events.PLATFORM_DISCONNECTED_EVENT:
        // Disconnected
//        console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Platform disconnected in global event handler")
        context.class_id = "";
        context.platform_state = false;
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
    //console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Received event: ", event)

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
                context.is_logged_in = true;

                // Update StatusBar
                status_bar_container_.visible = true
                var statusBar = createView(screens.STATUS_BAR, status_bar_container_)

                // Update Control by next state
                navigation_state_ = states.CONTROL_STATE
                updateState(events.SHOW_CONTROL_EVENT,null)

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
            case events.SHOW_CONTROL_EVENT:
                // Refresh Control View based on conditions
                if (context.platform_state){
                    // Show control when connected
                    var qml_control = getQMLFile(context.class_id, "Control")
                    createView(qml_control, control_container_)

                    // Restart timer of control
                    Metrics.restartTimer()
                }
                else {
                    // Disconnected; Show detection page
                    createView(screens.WELCOME_SCREEN, control_container_)
                }

                // Show content when we have a platform clasS_id; doesn't have to be actively connected
                if(context.class_id !== ""){
                    var qml_content = getQMLFile(context.class_id, "Content")
                    var contentObject = createView(qml_content, content_container_)

                    // Insert Listener
                    Metrics.injectEventToTree(contentObject)
                    Metrics.restartTimer()
                }
                else {
                    // Otherwise; no platform has been connected or chosen
                    removeView(content_container_)
                }
                break;

            case events.NEW_PLATFORM_CONNECTED_EVENT:
                // Cache platform name until we are ready to view
                console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "new platform connected data:", data.class_id)
                context.class_id = data.class_id
                context.platform_state = true;
                // Refresh
                updateState(events.SHOW_CONTROL_EVENT)
                break;

            case events.PLATFORM_DISCONNECTED_EVENT:
                context.platform_state = false;
                context.class_id = "";
                // Refresh
                updateState(events.SHOW_CONTROL_EVENT)
                break;

            case events.OFFLINE_MODE_EVENT:
                // Offline mode just keeps platform_state as false
                console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "Entering offline mode for ", data.class_id)
                context.class_id = data.class_id
                context.platform_state = false;
                updateState(events.SHOW_CONTROL_EVENT)
                break;

            case events.TOGGLE_CONTROL_CONTENT:
                // Send request to metrics service when entering and leaving platform control view
                var pageName = '';
                if(flipable_parent_.flipped===false){
                    console.log(LoggerModule.Logger.devStudioNavigationControlCategory, "In flipable ",context.class_id)
                    pageName = context.class_id +' Control'
                }else {
                    var currentTabName = Metrics.getCurrentTab()
                    pageName = context.class_id +' '+ currentTabName
                }

                Metrics.sendMetricsToCloud(pageName)

                // Flip to show control/content
                flipable_parent_.flipped = !flipable_parent_.flipped

                break;

            case events.SHOW_CONTROL:
                if (flipable_parent_.flipped) {
                    updateState(events.TOGGLE_CONTROL_CONTENT)
                }
                break;

            case events.SHOW_CONTENT:
                if (!flipable_parent_.flipped) {
                    updateState(events.TOGGLE_CONTROL_CONTENT)
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
