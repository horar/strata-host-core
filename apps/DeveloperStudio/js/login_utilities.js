/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
.pragma library

.import "restclient.js" as Rest
.import "utilities.js" as Utility
.import QtQuick 2.0 as QtQuickModule
.import "qrc:/js/platform_selection.js" as PlatformSelection
.import tech.strata.notification 1.0 as Notify

.import tech.strata.logger 1.0 as LoggerModule
.import tech.strata.signals 1.0 as SignalsModule

var initialized = false

/*
  Settings: Store/retrieve login information
*/
const settings = Utility.createObject("qrc:/partial-views/login/LoginSettings.qml", null)
const userSettings = Qt.createQmlObject(`import tech.strata.commoncpp 1.0; SGUserSettings {classId: "general-settings";}`, Qt.application, "SGUserSettings")

/*
  Login: Send information to server
*/
function login(login_info) {
    var data = {"username":login_info.user, "password":login_info.password, "timezone": login_info.timezone};

    userSettings.user = login_info.user

    let headers = {
        "app": "strata",
        "version": Rest.versionNumber(),
    }

    Rest.xhr("post", "login", data, login_result, login_error, headers)
    /*
      * Possible valid outcomes:
      *
      * token: <token>, user: <mail>, [firstname <first name>, lastname <last name>, tabs<tabs>], session <session id>
      *   - login valid, user can login
      * token: <token>, user: <mail>, [firstname <first name>, lastname <last name>, tabs<tabs>]
      *   - authorization server failed to create session, but login valid, user can login (maybe there will be limitations)
      *
      * Possible invalid outcomes:
      *
      * message: "No connection"
      *   - no connection to server, user should check internet connection
      * message: "Response not valid", status:<status code>, data:<response data>
      *   - non-json response, server is accesible, but authorization not running/broken, user should retry later
      * message: "Cannot login now", success: false
      *   - database returned error, user should retry later
      * message: "Bad Request"
      *   - malformed request sent to authorization server, user should re-enter values
      * message: "No user <mail>", success: false
      *   - account not found, user should re-enter mail
      * message: "Wrong password", success: false
      *   - password not matching, user should re-enter password
      * message: "Account is closed"
      *   - account inactive, user should enter different mail
    */
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
    if (response.hasOwnProperty("privacy_policy_changed") && response.privacy_policy_changed == true ) {
        console.warn(LoggerModule.Logger.devStudioLoginCategory, "Privacy Policy Update!")
        SignalsModule.Signals.privacyPolicyUpdate()
    }
    var result = {
        "response":"Connected",
        "jwt": response.token,
        "first_name": response.firstname,
        "last_name": response.lastname,
        "user_id": response.user,
        "consent_data_collection": response.consent_data_collection
    }

    // [TODO][prasanth]: jwt will be created/received in the hcs
    // for now, jwt will be received in the UI and then sent to HCS
    SignalsModule.Signals.loginResult(JSON.stringify(result))
}

/*
  Login: Callback on fail result from the REST object
*/
function login_error(error)
{
    console.error(LoggerModule.Logger.devStudioLoginCategory, "Login failed: ", JSON.stringify(error))
    if (error.message === "No connection") {
        SignalsModule.Signals.loginResult(JSON.stringify({"response":"No Connection"}))
    } else if ((error.message === 'Response not valid') || (error.message === 'Cannot login now')) {
        SignalsModule.Signals.loginResult(JSON.stringify({"response":"Server Error"}))
    } else {
        SignalsModule.Signals.loginResult(JSON.stringify({"response":"Bad Login Info"}))
    }
}

/*
  Login: Clear token on logout
*/
function logout() {
    if (Rest.session !== "") {
        Rest.xhr("get", "logout?session=" + Rest.session, "", logout_result, logout_error)
        Rest.jwt = ""
        Rest.session = ""
        if (settings.rememberMe) {
            settings.rememberMe = false
        }
    }

    /*
      * Possible valid outcomes:
      *
      * message: "session destroyed"
      *   - logout valid
      *
      * Possible invalid outcomes:
      *
      * message: "No connection"
      *   - no connection to server, user should check internet connection
      * message: "Response not valid", status:<status code>, data:<response data>
      *   - non-json response, server is accesible, but authorization not running/broken, user should retry later
      * message: "Invalid authentication token", success: false
      *   - unable to authentify user
      * message: "No authentication token provided", success: false
      *   - unable to authentify user
      * message: "no session"
      *   - unable to logout, session id is not valid
      * message: "Unauthorized", success: false
      *   - unable to logout, authorization failed
      * message: "something wrong"
      *   - unable to logout, session could not be closed
    */
}

function logout_result(response){
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Logout Successful:", response.message)
    SignalsModule.Signals.logout()
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
function close_session(callback) {
    if (Rest.session !== '' && Rest.jwt !== ''){
        var headers = {
            "app": "strata"
        }
        Rest.xhr("get", "session/close?session=" + Rest.session, "", close_session_result, close_session_result, headers)
        Rest.session = ""
        callback(true)
    } else {
        callback(false)
    }

    /*
      * Possible valid outcomes:
      *
      * message: "session closed"
      *   - session closed
      *
      * Possible invalid outcomes:
      *
      * message: "No connection"
      *   - no connection to server, user should check internet connection
      * message: "Response not valid", status:<status code>, data:<response data>
      *   - non-json response, server is accesible, but authorization not running/broken, user should retry later
      * message: "Invalid authentication token", success: false
      *   - unable to authentify user
      * message: "No authentication token provided", success: false
      *   - unable to authentify user
      * message: "session id required"
      *   - unable to close session, session id is missing
      * message: "unauthorized request"
      *   - unable to close session, authorization failed
      * message: "closing request received"
      *   - heartbeat acknowledged improperly, session not closed
    */
}

function close_session_result(response) {
    if (response.message ==="session closed"){
        console.log(LoggerModule.Logger.devStudioLoginCategory, "Session Close Successful")
    } else if (response.message === "closing request received") {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "Heartbeat improperly acknowldeged, session not closed")
    } else {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "Close Session error:", JSON.stringify(response))
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

    Rest.xhr("post", "signup", data, register_result, register_error, null)

    /*
      * Possible valid outcomes:
      *
      * message: "Account created", success: true
      *   - account created
      *
      * Possible invalid outcomes:
      *
      * message: "No connection"
      *   - no connection to server, user should check internet connection
      * message: "Response not valid", status:<status code>, data:<response data>
      *   - non-json response, server is accesible, but authorization not running/broken, user should retry later
      * message: "Cannot create user account", success: false
      *   - unable to create account, user should re-enter values
      * message: "Cannot create user account, user exists", success: false
      *   - unable to create account, user should re-enter different mail
    */
}

/*
  Registration: Callback on success result from the REST object
*/
function register_result(response)
{
    console.log(LoggerModule.Logger.devStudioLoginCategory, "Registration success!")
    SignalsModule.Signals.registrationResult("Registered")
}

/*
  Registration: Callback on fail result from the REST object
*/
function register_error(error)
{
    console.error(LoggerModule.Logger.devStudioLoginCategory, "Registration Failed: ", JSON.stringify(error))
    if (error.message === "No connection") {
        SignalsModule.Signals.registrationResult("No Connection")
    } else if (error.message === "Cannot create user account, user exists"){
        SignalsModule.Signals.registrationResult("Account already exists for this email address")
    } else if (error.message === 'Response not valid') {
        SignalsModule.Signals.registrationResult("Server Error")
    } else {
        SignalsModule.Signals.registrationResult("Bad Registration Request")
    }
}

/*
  Password Reset: Send reset request information to server
*/
function password_reset_request(request_info){
    var data = {"username":request_info.username};
    Rest.xhr("post", "resetPasswordRequest", data, password_reset_result, password_reset_error)

    /*
      * Possible valid outcomes:
      *
      * message: "Email with password reset instructions has been sent", success: true, [link: <link>]
      *   - password reset requested
      * message: "cannnot send email", success: false
      *   - unable to request reset password, failed to send mail (possibly invalid email address or broken mail server)
      * message: "No user found with email:<mail>", success: false
      *   - unable to request reset password, user should re-enter mail
      *
      * Possible invalid outcomes:
      *
      * message: "No connection"
      *   - no connection to server, user should check internet connection
      * message: "Response not valid", status:<status code>, data:<response data>
      *   - non-json response, server is accesible, but authorization not running/broken, user should retry later
      * message: "Account is closed", success: false
      *   - unable to request reset password, user should re-enter different mail
      * message: "username required"
      *   - missing mail, user should re-enter mail
      * message: "bad request"
      *   - malformed request sent to authorization server, user should re-enter values
    */
}

/*
  Password Reset: Callback function when we get a success result from the REST object
*/
function password_reset_result(response)
{
    if (!response.success) {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "Password Reset Request Failed: ", JSON.stringify(response))
        if (response.message === "cannnot send email") {
            SignalsModule.Signals.resetResult("Unable to send email")
        } else {
            SignalsModule.Signals.resetResult("No user found")
        }
    } else {
        console.log(LoggerModule.Logger.devStudioLoginCategory, "Password Reset Request Successful: ", JSON.stringify(response))
        SignalsModule.Signals.resetResult("Reset Requested")
    }
}

/*
  Password Reset: Callback function when we get a fail result from the REST object
*/
function password_reset_error(error)
{
    console.error(LoggerModule.Logger.devStudioLoginCategory, "Password Reset Error: ", JSON.stringify(error))
    if (error.message === "No connection") {
        SignalsModule.Signals.resetResult("No Connection")
    } else if (error.message === 'Response not valid') {
        SignalsModule.Signals.resetResult("Server Error")
    } else {
        SignalsModule.Signals.resetResult("Bad Request")
    }
}

/*
   Close Account: Send close account request to server
*/
function close_account(request_info) {
    var data = {"username":request_info.username};
    Rest.xhr("post", "closeAccount", data, close_account_result, close_account_result);

    /*
      * Possible valid outcomes:
      *
      * message: "Account closed"
      *   - account closed
      * message: "User not found"
      *   - unable to close account, user should re-enter values
      * message: "Cannot close account now"
      *   - unable to close account, user should retry later
      *
      * Possible invalid outcomes:
      *
      * message: "No connection"
      *   - no connection to server, user should check internet connection
      * message: "Response not valid", status:<status code>, data:<response data>
      *   - non-json response, server is accesible, but authorization not running/broken, user should retry later
      * message: "Invalid authentication token", success: false
      *   - unable to authentify user, user should logout and login again
      * message: "No authentication token provided", success: false
      *   - unable to authentify user, user should logout and login again
      * message: "Cannot close account"
      *   - unable to close account, user should re-enter values
      * message: "bad request"
      *   - malformed request sent to authorization server, user should re-enter values
    */
}

/*
  Close Account: Callback function for response from server
*/
function close_account_result(response) {
    if (response.message !== "Account closed") {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "Close Account Request Failed: ", JSON.stringify(response))
        if (response.message === "No connection") {
            SignalsModule.Signals.closeAccountResult("No Connection");
        } else if (response.message === 'Response not valid') {
            SignalsModule.Signals.closeAccountResult("Server Error")
        } else if ((response.message === 'Invalid authentication token') ||
                   (response.message === 'No authentication token provided')) {
            SignalsModule.Signals.closeAccountResult("Invalid Authentication")
        } else {
            SignalsModule.Signals.closeAccountResult("Bad Request");
        }
    } else {
        Rest.jwt = ""
        Rest.session = ""
        SignalsModule.Signals.closeAccountResult("Success");
    }
}

/*
  Get Profile: Get user's profile
*/
function get_profile(username) {
    var data = {"username": username};
    Rest.xhr("post", "profile", data, get_profile_result, get_profile_result_failed)

    /*
      * Possible valid outcomes:
      *
      * <profile data>
      *   - acquired profile data
      *
      * Possible invalid outcomes:
      *
      * message: "No connection"
      *   - no connection to server, user should check internet connection
      * message: "Response not valid", status:<status code>, data:<response data>
      *   - non-json response, server is accesible, but authorization not running/broken, user should retry later
      * message: "Invalid authentication token", success: false
      *   - unable to authentify user, user should logout and login again
      * message: "No authentication token provided", success: false
      *   - unable to authentify user, user should logout and login again
      * message: "unauthorized request"
      *   - unable to get profile, authorization failed, user should logout and login again
      * message: "Cannot retrieve profile"
      *   - unable to get profile, user should retry later
    */
}

/*
  Get Profile: Callback function for response from server
*/
function get_profile_result(response) {
    SignalsModule.Signals.getProfileResult("Success", response)
}

/*
  Get Profile: Callback function for response from server on error
*/
function get_profile_result_failed(response) {
    console.error(LoggerModule.Logger.devStudioLoginCategory, "Get Profile request failed: ", JSON.stringify(response))
    if (response.message === "No connection") {
        SignalsModule.Signals.getProfileResult("No Connection", null);
    } else if (response.message === 'Response not valid') {
        SignalsModule.Signals.getProfileResult("Server Error", null)
    } else if ((response.message === 'Invalid authentication token') ||
               (response.message === 'No authentication token provided') ||
               (response.message === 'unauthorized request')) {
        SignalsModule.Signals.getProfileResult("Invalid Authentication", null)
    } else {
        SignalsModule.Signals.getProfileResult("Failed to get profile", null);
    }
}

/*
    Update Profile: Send update profile request to server
*/
function update_profile(username, updated_properties) {
    var data = updated_properties;
    data._id = username;

    if (updated_properties.hasOwnProperty("password")) {
       Rest.xhr("post", "profileUpdate", data, change_password_result, change_password_result)
    } else if(updated_properties.hasOwnProperty("consent_privacy_policy")) {
        Rest.xhr("post", "profileUpdate", data, update_profile_result, update_profile_result)
    } else {
       Rest.xhr("post", "profileUpdate", data, update_profile_result, update_profile_result)
    }

    /*
      * Possible valid outcomes:
      *
      * message: "Profile update successful"
      *   - profile updated
      *
      * Possible invalid outcomes:
      *
      * message: "No connection"
      *   - no connection to server, user should check internet connection
      * message: "Response not valid", status:<status code>, data:<response data>
      *   - non-json response, server is accesible, but authorization not running/broken, user should retry later
      * message: "Invalid authentication token", success: false
      *   - unable to authentify user, user should logout and login again
      * message: "No authentication token provided", success: false
      *   - unable to authentify user, user should logout and login again
      * message: "unauthorized request"
      *   - unable to get profile, authorization failed, user should logout and login again
      * message: "Cannot update profile"
      *   - unable to update profile, user should retry later
    */
}

/*
  Update Profile Result: Callback function for response from update profile request
*/
function update_profile_result(response, updatedProperties) {
    if (response.message === "Profile update successful") {
        SignalsModule.Signals.profileUpdateResult("Success", updatedProperties)
    } else {
        if (response.message === "No connection") {
            SignalsModule.Signals.profileUpdateResult("No Connection", updatedProperties);
        } else if (response.message === 'Response not valid') {
            SignalsModule.Signals.profileUpdateResult("Server Error", updatedProperties);
        } else if ((response.message === 'Invalid authentication token') ||
                   (response.message === 'No authentication token provided') ||
                   (response.message === 'unauthorized request')) {
            SignalsModule.Signals.profileUpdateResult("Invalid Authentication", updatedProperties);
        } else {
            SignalsModule.Signals.profileUpdateResult("Failed to update profile", updatedProperties);
        }
    }
}

/*
  Change Password Result: Callback function for response from change password request
*/
function change_password_result(response) {
    if (response.message === "Profile update successful") {
        SignalsModule.Signals.changePasswordResult("Success")
    } else {
        if (response.message === "No connection") {
            SignalsModule.Signals.changePasswordResult("No Connection");
        } else if (response.message === 'Response not valid') {
            SignalsModule.Signals.changePasswordResult("Server Error");
        } else if ((response.message === 'Invalid authentication token') ||
                   (response.message === 'No authentication token provided') ||
                   (response.message === 'unauthorized request')) {
            SignalsModule.Signals.changePasswordResult("Invalid Authentication");
        } else {
            SignalsModule.Signals.changePasswordResult("Failed to change password");
        }
    }
}

/*
  Validate token: if a JWT exists from previous session, send it for server to validate and start new session
*/
function validate_token()
{
    if (Rest.jwt !== "" && settings.user !== ""){
        userSettings.user = settings.user

        let headers = {
            "app": "strata",
            "version": Rest.versionNumber(),
        }

        Rest.xhr("get", "session/init", "", validation_result, validation_result, headers)
    } else {
        console.error(LoggerModule.Logger.devStudioLoginCategory, "No JWT to validate, or no username saved")
    }

    /*
      * Possible valid outcomes:
      *
      * token: <token>, user: <mail>, [firstname <first name>, lastname <last name>, tabs<tabs>], session <session id>
      *   - login valid, user can login
      * token: <token>, user: <mail>, [firstname <first name>, lastname <last name>, tabs<tabs>]
      *   - authorization server failed to create session, but login valid, user can login (maybe there will be limitations)
      *
      * Possible invalid outcomes:
      *
      * message: "No connection"
      *   - no connection to server, user should check internet connection
      * message: "Response not valid", status:<status code>, data:<response data>
      *   - non-json response, server is accesible, but authorization not running/broken, user should retry later
      * message: "Invalid authentication token", success: false
      *   - unable to authentify user
      * message: "No authentication token provided", success: false
      *   - unable to authentify user
      * message: "unauthorized request"
      *   - unable to init session, authorization failed
    */
}

function validation_result (response) {
    if (response.hasOwnProperty("session")) {
        Rest.session = response.session;
        SignalsModule.Signals.validationResult("Current token is valid")

        if (response.hasOwnProperty("privacy_policy_changed") && response.privacy_policy_changed == true ) {
            console.warn(LoggerModule.Logger.devStudioLoginCategory, "Privacy Policy Update!")
            SignalsModule.Signals.privacyPolicyUpdate()
        }

    } else {
        Rest.jwt = ""
        if (response.message === "No connection") {
            SignalsModule.Signals.validationResult("No Connection")
        } else if (response.message === 'Response not valid') {
            SignalsModule.Signals.validationResult("Server Error");
        } else if ((response.message === 'Invalid authentication token') ||
                   (response.message === 'No authentication token provided') ||
                   (response.message === 'unauthorized request')) {
            SignalsModule.Signals.validationResult("Invalid Authentication");
        } else {
            SignalsModule.Signals.validationResult("Error")
        }
    }
}


function heartbeat () {
    if (Rest.session !== '' && Rest.jwt !== ''){
        var headers = {
            "app": "strata",
            "heartbeat": 1
        }
        Rest.xhr("get", "session/close?session=" + Rest.session, "", heartbeat_result, heartbeat_result, headers)
    }

    /*
      * Possible valid outcomes:
      *
      * message: "closing request received"
      *   - heartbeat acknowledged
      *
      * Possible invalid outcomes:
      *
      * message: "session closed"
      *   - heartbeat header not set, session closed instead of heartbeat acknowledged
      * message: "session id required"
      *   - session string not sent
      * message: "No connection"
      *   - no connection to server, user should check internet connection
      * message: "Response not valid", status:<status code>, data:<response data>
      *   - non-json response, server is accesible, but authorization not running/broken, user should retry later
      * message: "Invalid authentication token", success: false
      *   - unable to authenticate user
      * message: "No authentication token provided", success: false
      *   - unable to authenticate user
      * message: "unauthorized request"
      *   - unable to close session, authorization failed
    */
}

function heartbeat_result (response) {
    if (response.hasOwnProperty("message")) {
        if (response.message === "closing request received") {
            // console.log(LoggerModule.Logger.devStudioLoginCategory, "Heartbeat acknowledged")
        } else if (response.message === 'session closed') {
            console.error(LoggerModule.Logger.devStudioLoginCategory, "Heartbeat closed session improperly")
        } else {
            console.error(LoggerModule.Logger.devStudioLoginCategory, "Close Session error:", JSON.stringify(response))
        }
    }
}

function set_token (token) {
    Rest.jwt = token
}

function getNextId() {
   return Rest.getNextRequestId();
}

function checkHcsStatus() {
    var reply = PlatformSelection.sdsModel.strataClient.sendRequest("hcs_status", {});

    reply.finishedSuccessfully.connect(function(result) {
        let errorList = result["error_list"]
        if (errorList && errorList.length > 0) {
            console.warn(LoggerModule.Logger.devStudioLoginCategory, "HCS status:", errorList.length, "issue(s) found:")
            for (var i = 0; i < errorList.length; ++i) {
                console.warn(LoggerModule.Logger.devStudioLoginCategory, errorList[i].code, errorList[i].message)

                PlatformSelection.sdsModel.notificationModel.create(
                            {
                                "title": "Host Controller Service issue found",
                                "description": formatIssueText(errorList[i].message),
                                "level": Notify.Notification.Warning,
                                "removeAutomatically": false,
                            }
                            )
            }

        } else {
            console.info(LoggerModule.Logger.devStudioLoginCategory, "HCS status: everything ok")
        }
    })

    reply.finishedWithError.connect(function(error) {
        console.warn(LoggerModule.Logger.devStudioLoginCategory, "Request for HCS status failed", JSON.stringify(error))
    })
}

function formatIssueText(text) {
    var t = text.charAt(0).toUpperCase() + text.slice(1)
    return t
}
