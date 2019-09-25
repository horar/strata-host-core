.pragma library

.import tech.strata.logger 1.0 as LoggerModule

var url = "https://strata.onsemi.com/";

// jwt will be set after successful login
var jwt = '';
var cachedState

var xhr = function(method, endpoint, data, callback, errorCallback, signals) {
    cachedState = {
        "status": -1,
        "responseText": ""
    }

    var xhr = new XMLHttpRequest();

    var timeOut = Qt.createQmlObject("import QtQuick 2.3; Timer {interval: 10000; repeat: false; running: true;}",Qt.application,"TimeOut");
    timeOut.triggered.connect(function(){
        if (xhr) {
            xhr.abort();
            console.error(LoggerModule.Logger.devStudioRestClientCategory, "Error: request timed out")
        }
        timeOut.destroy()
    });

    if (signals) {
        signals.connectionStatus(xhr.readyState)  // Send connection status updates to UI
    }

    xhr.onreadystatechange = function() {
            if ( xhr.readyState === 4 && xhr.status >= 200 && xhr.status < 300) {
                //console.log(LoggerModule.Logger.devStudioRestClientCategory, xhr.responseText)
                callback( JSON.parse(xhr.responseText) );
                timeOut.destroy()
            }
            else if (xhr.readyState === 4 && xhr.status >= 300) {
                if (errorCallback) {
                    var response = xhr.responseText;
                    try{
                        response = JSON.parse(xhr.responseText);
                    }catch(error){
                        console.error(LoggerModule.Logger.devStudioRestClientCategory, "error response not json: " + error)
                    }
                    errorCallback(response);
                    timeOut.destroy()
                }
            }
            // No connection to db - readyState is 4 (request complete)
            else if (xhr.readyState === 4 && xhr.status === 0 ) {
                if (cachedState.status === 409 && cachedState.responseText !== "") {
                    // Workaround for 409 server response: https://bugreports.qt.io/browse/QTBUG-49896
                    // (409 response causes XHR to crash between states 3 and 4, causing false positive "No connection")
                    var response = cachedState.responseText;
                    try{
                        response = JSON.parse(cachedState.responseText);
                    }catch(error){
                        console.error(LoggerModule.Logger.devStudioRestClientCategory, "error response not json: " + error)
                    }
                    errorCallback(response)
                } else {
                    errorCallback({message: "No connection"})
                }
                timeOut.destroy()
            }
            // Send connection status updates to UI
            else if (signals) {
                if (xhr.readyState === 3) {
                    cachedState.status = xhr.status
                    cachedState.responseText = xhr.responseText
                }

                signals.connectionStatus(xhr.readyState)
            }
        };

    var fullUrl = url + endpoint;
    xhr.open( method, fullUrl );

    // This must be after open
    xhr.setRequestHeader("Content-Type","application/json");

    // Set JWT in the requst header
    if (jwt !== '') {
        //console.log(LoggerModule.Logger.devStudioRestClientCategory, "JWT", jwt)
        xhr.setRequestHeader("x-access-token",jwt);
    }

    xhr.send(JSON.stringify(data));
}
