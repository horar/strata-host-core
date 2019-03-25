.import "restclient.js" as Rest
.import QtQuick 2.0 as QtQuickModule

.import Strata.Logger 1.0 as LoggerModule

/*
  Signal component to notify Login status
*/
var signals = createObject("qrc:/SGSignals.qml", null)

/*
  Send Login information to server
*/
function login(login_info){
    var data = {"username":login_info.user,"password":login_info.password};
    Rest.xhr("post", "login", data, login_result, login_error, signals)
}

/*
  Callback function when we get a success result from the REST object
*/
function login_result(response)
{
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Login success! ", JSON.stringify(response))

    if(response.hasOwnProperty("token")){
        Rest.jwt = response.token;
    }
    signals.loginResult("Connected")
    // [TODO][prasanth]: jwt will be created/received in the hcs
    // for now, jwt will be received in the UI and then sent to HCS
    signals.loginJWT(response.token)
}

/*
  Callback function when we get a fail result from the REST object
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
  Dynamically load qml controls by qml filename
*/
function createObject(name, parent) {
    console.log(LoggerModule.Logger.devStudioLoginCategory, "createObject: name =", name)

    var component = Qt.createComponent(name, QtQuickModule.Component.PreferSynchronous, parent);

    if (component.status === QtQuickModule.Component.Error) {
        console.log(LoggerModule.Logger.devStudioLoginCategory, "ERROR: Cannot createComponent ", name);
    }

    // TODO[Abe]: store this globally for later destroying
    var object = component.createObject(parent)
    if (object === null) {
        console.log(LoggerModule.Logger.devStudioLoginCategory, "Error creating object: name=", name);
    }

    return object;
}
