.pragma library

.import "restclient.js" as Rest
.import QtQuick 2.0 as QtQuickModule

.import tech.strata.logger 1.0 as LoggerModule

/*
  Signals: Signal component to notify Login status
*/
var signals = createObject("qrc:/partial-views/login/LoginSignals.qml", null)

/*
  Login: Send information to server
*/
function login(login_info){
    var data = {"username":login_info.user,"password":login_info.password};
    Rest.xhr("post", "login", data, login_result, login_error, signals)
}

/*
  Login: Callback on success result from the REST object
*/
function login_result(response)
{
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Login success!")
    if(response.hasOwnProperty("token")){
        Rest.jwt = response.token;
    }
    signals.loginResult("Connected")
    // [TODO][prasanth]: jwt will be created/received in the hcs
    // for now, jwt will be received in the UI and then sent to HCS
    signals.loginJWT(response.token)
}

/*
  Login: Callback on fail result from the REST object
*/
function login_error(error)
{
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Login Error : ", JSON.stringify(error))
    if (error.message === "No connection") {
        signals.loginResult("No Connection")
    } else {
        signals.loginResult("Bad Login Info")
    }
}

/*
  Login: Clear token on logout
*/
function logout() {
    Rest.jwt = ""
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
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Registration Error : ", JSON.stringify(error))
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
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Password Reset Request Response: ", JSON.stringify(response))

    if (!response.success) {
        signals.resetResult("No user found")
    } else {
        signals.resetResult("Reset Requested")
    }
}

/*
  Password Reset: Callback function when we get a fail result from the REST object
*/
function password_reset_error(error)
{
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Password Reset Error: ", JSON.stringify(error))
    if (error.message === "No connection") {
        signals.resetResult("No Connection")
    } else {
        signals.resetResult("Bad Request")
    }
}

/*
  Utilities: Dynamically load qml controls by qml filename
*/
function createObject(name, parent) {
    console.log(LoggerModule.Logger.devStudioLoginCategory, "createObject: name =", name)

    var component = Qt.createComponent(name, QtQuickModule.Component.PreferSynchronous, parent);

    if (component.status === QtQuickModule.Component.Error) {
        console.log(LoggerModule.Logger.devStudioLoginCategory, "ERROR: Cannot createComponent ", name);
    }

    var object = component.createObject(parent)
    if (object === null) {
        console.log(LoggerModule.Logger.devStudioLoginCategory, "Error creating object: name=", name);
    }

    return object;
}

/*
  Utilities: Destroy dynamically created objects
*/
function destroyObject (object) {
    object.destroy()
}

