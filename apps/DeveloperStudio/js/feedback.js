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
.import tech.strata.logger 1.0 as LoggerModule
.import tech.strata.signals 1.0 as SignalsModule

/*
  Send Feedback information to server
*/

function feedbackInfo(feedback_info){
    let headers = {
        "app": "strata",
        "version": Rest.versionNumber(),
    }

    var data = {"email": feedback_info.email, "name": feedback_info.name, "comment" : feedback_info.comment };
    Rest.xhr("post", "feedbacks", data, feedback_result, feedback_error, headers);

    /*
      * Possible valid outcomes:
      *
      * message: "Data added", error: false
      *   - feedback sent
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
      *   - unable to send feedback, authorization failed, user should logout and login again
      * message: "Empty fields are not accepted"
      *   - malformed request sent, user should re-enter values
      * message: "Something went wrong when saving feedback to the DB"
      *   - error in database, user should retry later
      * message: "name, email, comment all are required fields"
      *   - malformed request sent, user should re-enter values
      * message: "Bad request"
      *   - malformed request sent, user should re-enter values
    */
}

function feedback_result(response) {
    console.log(LoggerModule.Logger.devStudioFeedbackCategory, "Feedback successfully sent")
        SignalsModule.Signals.feedbackResult("Feedback successfully sent")
}

function feedback_error(response) {
    console.log(LoggerModule.Logger.devStudioFeedbackCategory, "Feedback failed to send: ", JSON.stringify(response))
    if (response.message === "No connection") {
        SignalsModule.Signals.feedbackResult("No Connection")
    } else if (response.message === 'Response not valid') {
        SignalsModule.Signals.feedbackResult("Server Error");
    } else if ((response.message === 'Invalid authentication token') ||
               (response.message === 'No authentication token provided') ||
               (response.message === 'unauthorized request')) {
        SignalsModule.Signals.feedbackResult("Invalid Authentication");
    } else {
        SignalsModule.Signals.feedbackResult("Bad Request")
    }
}

function getNextId(){
   return Rest.getNextRequestId();
}
