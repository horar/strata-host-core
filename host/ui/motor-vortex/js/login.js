.import "restclient.js" as Rest
.import QtQuick 2.0 as QtQuickModule

/*
  Signal component to notify Login status
*/
var signals = createObject("qrc:/SGSignals.qml", null)

/*
  Send Login information to server
*/
function login(login_info){
    var data = {"username":login_info.user,"password":login_info.password};
    Rest.xhr("post","login",data,
             login_result, login_error)
}

/*
  Callback function when we get a success result from the REST object
*/
function login_result(response)
{
    console.log("Login success! ", response)
    signals.loginResult(true)
}

/*
  Callback function when we get a fail result from the REST object
*/
function login_error(error)
{
    console.log("Login Error : ", error)
    signals.loginResult(false)
}

/*
  Dynamically load qml controls by qml filename
*/
function createObject(name, parent) {
    console.log("createObject: name =", name)

    var component = Qt.createComponent(name, QtQuickModule.Component.PreferSynchronous, parent);

    if (component.status === QtQuickModule.Component.Error) {
        console.log("ERROR: Cannot createComponent ", name);
    }

    // TODO[Abe]: store this globally for later destroying
    var object = component.createObject(parent)
    if (object === null) {
        console.log("Error creating object: name=", name);
    }

    return object;
}
