.pragma library

.import "restclient.js" as Rest
.import QtQuick 2.0 as QtQuickModule

.import tech.strata.logger 1.0 as LoggerModule

var initialized = false

/*
  Settings: Store/retrieve login information
*/
var settings = createObject("qrc:/partial-views/login/LoginSettings.qml", null)

/*
  Signals: Signal component to notify Login status
*/
var signals = createObject("qrc:/partial-views/login/LoginSignals.qml", null)

/*
  Login: Send information to server
*/
function login(login_info){
    var data = {"username":login_info.user, "password":login_info.password, "timezone": login_info.timezone};

    let headers = {
        "app": "strata",
        "version": Rest.versionNumber(),
    }

    Rest.xhr("post", "login", data, login_result, login_error, signals, headers)
}

/*
  Login: Callback on success result from the REST object
*/
function login_result(response)
{
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Login success!")
    if (response.hasOwnProperty("token")) {
        Rest.jwt = response.token;
    }
    if (response.hasOwnProperty("session")) {
        Rest.session = response.session;
    }
    var result = {
        "response":"Connected",
        "jwt": response.token,
        "first_name": response.firstname,
        "last_name": response.lastname,
        "user_id": response.user
    }

    // [TODO][prasanth]: jwt will be created/received in the hcs
    // for now, jwt will be received in the UI and then sent to HCS
    signals.loginResult(JSON.stringify(result))
}

/*
  Login: Callback on fail result from the REST object
*/
function login_error(error)
{
    console.error(LoggerModule.Logger.devStudioLoginCategory, "Login failed: ", JSON.stringify(error))
    if (error.message === "No connection") {
        signals.loginResult(JSON.stringify({"response":"No Connection"}))
    } else {
        signals.loginResult(JSON.stringify({"response":"Bad Login Info"}))
    }
}

/*
  Login: Clear token on logout
*/
function logout() {
    Rest.xhr("get", "logout?session=" + Rest.session, "", logout_result, logout_error)//, signals)
    Rest.jwt = ""
    Rest.session = ""
    if (settings.rememberMe) {
        settings.rememberMe = false
    }
}

function logout_result(response){
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Logout Successful:", response.message)
}

function logout_error(error){
    if (error.message === "No connection") {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "Unable to connect to authentication server to log out")
    } else {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "Logout error:", JSON.stringify(error))
    }
}

/*
  Login: Close session
*/
function close_session() {
    if (Rest.session !== '' && Rest.jwt !== ''){
        var headers = {"app": "strata"}
        Rest.xhr("get", "session/close?session=" + Rest.session, "", close_session_result, close_session_result, undefined, headers)
    }
}

function close_session_result(response) {
    Rest.session = ""
//    if (response.message ==="session closed"){
//        console.log(LoggerModule.Logger.devStudioLoginCategory, "Session Close Successful")
//    } else {
//        console.error(LoggerModule.Logger.devStudioLoginCategory, "Close Session error:", JSON.stringify(response))
//    }
}

/*
  Registration: Send Registration information to server
*/
function register(registration_info){
    var data = {
        "firstname":registration_info.firstname,
        "lastname":registration_info.lastname,
        "admin":registration_info.admin,
        "username":registration_info.username,
        "password":registration_info.password,
        "title": registration_info.title,
        "company": registration_info.company
    };
    Rest.xhr("post", "signup", data, register_result, register_error, signals)
}

/*
  Registration: Callback on success result from the REST object
*/
function register_result(response)
{
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Registration success!")
    signals.registrationResult("Registered")
}

/*
  Registration: Callback on fail result from the REST object
*/
function register_error(error)
{
    console.error(LoggerModule.Logger.devStudioLoginCategory, "Registration Failed: ", JSON.stringify(error))
    if (error.message === "No connection") {
        signals.registrationResult("No Connection")
    } else if (error.message === "Cannot create user account, user exists"){
        signals.registrationResult("Account already exists for this email address")
    } else {
        signals.registrationResult("Bad Registration Request")
    }
}

/*
  Password Reset: Send reset request information to server
*/
function password_reset_request(request_info){
    var data = {"username":request_info.username};
    Rest.xhr("post", "resetPasswordRequest", data, password_reset_result, password_reset_error, signals)
}

/*
  Password Reset: Callback function when we get a success result from the REST object
*/
function password_reset_result(response)
{
    if (!response.success) {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "Password Reset Request Failed: ", JSON.stringify(response))
        signals.resetResult("No user found")
    } else {
        console.log(LoggerModule.Logger.devStudioLoginCategory, "Password Reset Request Successful: ", JSON.stringify(response))
        signals.resetResult("Reset Requested")
    }
}

/*
  Password Reset: Callback function when we get a fail result from the REST object
*/
function password_reset_error(error)
{
    console.error(LoggerModule.Logger.devStudioLoginCategory, "Password Reset Error: ", JSON.stringify(error))
    if (error.message === "No connection") {
        signals.resetResult("No Connection")
    } else {
        signals.resetResult("Bad Request")
    }
}

/*
   Close Account: Send close account request to server
*/
function close_account(request_info) {
    var data = {"username":request_info.username};
    Rest.xhr("post", "closeAccount", data, close_account_result, close_account_result, signals);
}

/*
  Close Account: Callback function for response from server
*/
function close_account_result(response) {
    if (response.message !== "Account closed") {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "Close Account Request Failed: ", JSON.stringify(response))
        if (response.message === "No connection") {
            signals.closeAccountResult("No Connection");
        } else {
            signals.closeAccountResult(response.message);
        }
    } else {
        signals.closeAccountResult("Success");
    }
}

/*
  Get Profile: Get user's profile
*/
function get_profile(username) {
    var data = {"username": username};
    Rest.xhr("post", "profile", data, get_profile_result, get_profile_result_failed, signals)
}

/*
  Get Profile: Callback function for response from server
*/
function get_profile_result(response) {
    signals.getProfileResult("Success", response)
}

/*
  Get Profile: Callback function for response from server on error
*/
function get_profile_result_failed(response) {
    console.error(LoggerModule.Logger.devStudioLoginCategory, "Get Profile request failed: ", JSON.stringify(response))
    signals.getProfileResult("Failed to get profile", null)
}

/*
    Update Profile: Send update profile request to server
*/
function update_profile(username, updated_properties) {
    var data = updated_properties;
    data._id = username;

    if (updated_properties.hasOwnProperty("password")) {
        Rest.xhr("post", "profileUpdate", data, change_password_result, change_password_result, signals)
    } else {
        Rest.xhr("post", "profileUpdate", data, update_profile_result, update_profile_result, signals)
    }
}

/*
  Update Profile Result: Callback function for response from update profile request
*/
function update_profile_result(response) {
    if (response.message === "Profile update successful") {
        signals.profileUpdateResult("Success")
    } else {
        signals.profileUpdateResult(response.message)
    }
}

/*
  Change Password Result: Callback function for response from change password request
*/
function change_password_result(response) {
    if (response.message === "Profile update successful") {
        signals.changePasswordResult("Success")
    } else {
        signals.changePasswordResult(response.message)
    }
}

/*
  Validate token: if a JWT exists from previous session, send it for server to validate and start new session
*/
function validate_token()
{
    if (Rest.jwt !== ""){
        var headers = {"app": "strata"}
        Rest.xhr("get", "session/init", "", validation_result, validation_result, undefined, headers)
    } else {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "No JWT to validate")
    }
}

function validation_result (response) {
    if (response.hasOwnProperty("session")) {
        Rest.session = response.session;
        signals.validationResult("Current token is valid")
    } else {
        Rest.jwt = ""
        if (response.message === "Invalid authentication token") {
            signals.validationResult("Invalid authentication token")
        } else if (response.message === "No connection") {
            signals.validationResult("No Connection")
        } else {
            signals.validationResult("Error")
        }
    }
}

function set_token (token) {
    Rest.jwt = token
}

/*
  Utilities: Dynamically load qml controls by qml filename
*/
function createObject(name, parent) {
    console.log(LoggerModule.Logger.devStudioLoginCategory, "createObject: name =", name)

    var component = Qt.createComponent(name, QtQuickModule.Component.PreferSynchronous, parent);

    if (component.status === QtQuickModule.Component.Error) {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "Cannot createComponent:", name, "; err=", component.errorString());
    }

    var object = component.createObject(parent)
    if (object === null) {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "Cannot createObject:", name);
    }

    return object;
}

/*
  Utilities: Destroy dynamically created objects
*/
function destroyObject (object) {
    object.destroy()
}

