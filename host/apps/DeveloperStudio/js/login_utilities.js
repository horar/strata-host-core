.pragma library

.import "restclient.js" as Rest
.import QtQuick 2.0 as QtQuickModule

.import tech.strata.logger 1.0 as LoggerModule

var initialized = false

/*
  Signals: Signal component to notify Login status
*/
var signals = createObject("qrc:/partial-views/login/LoginSignals.qml", null)

/*
  Login: Send information to server
*/
function login(login_info){
    var data = {"username":login_info.user, "password":login_info.password, "timezone": login_info.timezone};
    var headers = {"app": "strata"}
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
  Validate token: if a JWT exists from previous session, send it for server to validate
*/
function validate_token()
{
    if (Rest.jwt !== ""){
        var data = {"page":"login"}
        Rest.xhr("post", "metrics/1", data, validation_result, validation_result, signals)
    } else {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "No JWT to validate")
    }
}

function validation_result (response) {
    if (response.message === "all metrics fields: time, howLong, page should be set") {
        signals.validationResult("Current token is valid")
    } else if (response.message === "unauthorized request") {
        Rest.jwt = ""
        signals.validationResult("Invalid authentication token")
    } else if (response.message === "No connection") {
        Rest.jwt = ""
        signals.validationResult("No Connection")
    } else {
        Rest.jwt = ""
        signals.validationResult("Error")
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
        console.error(LoggerModule.Logger.devStudioLoginCategory, "Cannot createComponent:", name);
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

