/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
.pragma library

.import tech.strata.logger 1.0 as LoggerModule
.import tech.strata.signals 1.0 as SignalsModule

var urlObject = Qt.createQmlObject('import QtQuick 2.0; Text { text: sdsModel.urls.authServer }', Qt.application, 'urlObject');
var url = urlObject.text;

var jwt = '';
var session = '';
var cachedState
var version_ = ""
var currentrequestId_ = -1
const signals = SignalsModule.Signals;

// Attempt to read authentication server endpoint from QtSettings/INI file ("Login" category)
// Use default (production) endpoint if variable 'authentication_server' is undefined/empty
var get_auth_server = Qt.createQmlObject("import Qt.labs.settings 1.1; Settings {category: \"Login\";}", Qt.application)
if (get_auth_server.value("authentication_server")) {
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Found 'authentication_server' field in INI file (" + get_auth_server.value("authentication_server") + ")")
    url = get_auth_server.value("authentication_server")
}

var xhr = function(method, endpoint, data, callback, errorCallback, headers) {
    cachedState = {
        "status": -1,
        "responseText": ""
    }

    var xhr = new XMLHttpRequest();

    currentrequestId_ += 1
    signals.connectionStatus(xhr.readyState, currentrequestId_);

    var timeOut = Qt.createQmlObject("import QtQuick 2.3; Timer {interval: 10000; repeat: false; running: true;}",Qt.application,"TimeOut");
    timeOut.triggered.connect(function(){
        if (xhr) {
            xhr.abort();
            console.error(LoggerModule.Logger.devStudioRestClientCategory, "Error: request timed out")
        }
        timeOut.destroy()
    });

    xhr.onreadystatechange = function() {
        var response;
        if (xhr.readyState === 3) {
            cachedState.status = xhr.status
            cachedState.responseText = xhr.responseText
        }
        else if (xhr.readyState === 4 && xhr.status >= 200 && xhr.status < 300) {
            //console.log(LoggerModule.Logger.devStudioRestClientCategory, xhr.responseText)
            var validResponse;
            try {
                response = JSON.parse(xhr.responseText);
                validResponse = true
            } catch (error) {
                console.error(LoggerModule.Logger.devStudioRestClientCategory, "Error; response not json: " + error)
                response = {"message":"Response not valid","status":xhr.status,"data":JSON.stringify(xhr.responseText)}
                validResponse = false
            }
            if (validResponse) {
                if (callback.length > 1) {
                    callback(response, data)
                } else {
                    callback(response);
                }
            } else {
                errorCallback(response);
            }
            timeOut.destroy()
        }
        else if (xhr.readyState === 4 && xhr.status >= 300) {
            if (errorCallback) {
                //console.log(LoggerModule.Logger.devStudioRestClientCategory, xhr.responseText)
                try {
                    response = JSON.parse(xhr.responseText);
                } catch (error) {
                    console.error(LoggerModule.Logger.devStudioRestClientCategory, "Error; response not json: " + error)
                    response = {"message":"Response not valid","status":xhr.status,"data":JSON.stringify(xhr.responseText)}
                }
                errorCallback(response);
                timeOut.destroy()
            }

            if (xhr.status === 401) {
                console.error(LoggerModule.Logger.devStudioRestClientCategory, "user not authenticated, session probably expired")

                jwt = ""
                session = ""
                signals.sessionExpired()
            }
        }
        // No connection to db - readyState is 4 (request complete)
        else if (xhr.readyState === 4 && xhr.status === 0 ) {
            if (cachedState.status === 409 && cachedState.responseText !== "") {
                // Workaround for 409 server response: https://bugreports.qt.io/browse/QTBUG-49896
                // (409 response causes XHR to crash between states 3 and 4, causing false positive "No connection")
                try {
                    response = JSON.parse(cachedState.responseText);
                } catch (error) {
                    console.error(LoggerModule.Logger.devStudioRestClientCategory, "Error; response not json: " + error)
                    response = {"message":"Response not valid","status":cachedState.status,"data":JSON.stringify(cachedState.responseText)}
                }
                errorCallback(response)
            } else {
                errorCallback({"message":"No connection"})
            }
            timeOut.destroy()
        }
        // Send connection status updates to UI
        signals.connectionStatus(xhr.readyState, currentrequestId_);
    };

    var fullUrl = url + endpoint;
    xhr.open( method, fullUrl );

    // This must be after open
    xhr.setRequestHeader("Content-Type","application/json");

    // Set JWT in the request header
    if (jwt !== '') {
        //console.log(LoggerModule.Logger.devStudioRestClientCategory, "JWT", jwt)
        xhr.setRequestHeader("x-access-token",jwt);
    }

    if (headers) {
        for (var header in headers) {
            if (headers.hasOwnProperty(header)) {
                xhr.setRequestHeader(header, headers[header])
            }
        }
    }

    xhr.send(JSON.stringify(data));
}

function versionNumber() {
    if (version_ === ""){
        let versionNumberList = Qt.application.version.split(".")
        if (versionNumberList[0].startsWith("v")) {
            versionNumberList[0] = versionNumberList[0].substring(1)
        }
        version_ ="%1.%2.%3".arg(versionNumberList[0]).arg(versionNumberList[1]).arg(versionNumberList[2])
    }
    return version_
}

function getNextRequestId() {
    return currentrequestId_ + 1
}
