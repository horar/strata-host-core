.pragma library

var url = "http://18.222.75.160/";

// jwt will be set after successful login
var jwt = '';

var xhr = function(method, endpoint, data, callback, errorCallback, signals) {

    var xhr = new XMLHttpRequest();

    if (signals) {
        signals.connectionStatus(xhr.readyState)  // Send connection status updates to UI
    }

    xhr.onreadystatechange = function() {
            if ( xhr.readyState === 4 && xhr.status >= 200 && xhr.status < 300) {
                //console.log(xhr.responseText)
                callback( JSON.parse(xhr.responseText) );
            }
            else if (xhr.readyState === 4 && xhr.status >= 300) {
                if (errorCallback) {
                    errorCallback(JSON.parse(xhr.responseText));
                }
            }
            // No connection to db - readyState is 4 (request complete)
            else if (xhr.readyState === 4 && !xhr.hasOwnProperty("status")) {
                errorCallback({message: "No connection"})
            }
            // Send connection status updates to UI
            else if (signals) {
                signals.connectionStatus(xhr.readyState)
            }
        };

    var fullUrl = url + endpoint;
    xhr.open( method, fullUrl );

    // This must be after open
    xhr.setRequestHeader("Content-Type","application/json");

    // Set JWT in the requst header
    if (jwt !== '') {
        console.log("JWT", jwt)
        xhr.setRequestHeader("x-access-token",jwt);
    }

    xhr.send(JSON.stringify(data));
}
