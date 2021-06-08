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
}

function feedback_result(response) {
    console.log(LoggerModule.Logger.devStudioFeedbackCategory, "Feedback successfully sent")
        SignalsModule.Signals.feedbackResult("Feedback successfully sent")
}

function feedback_error(response) {
    console.log(LoggerModule.Logger.devStudioFeedbackCategory, "Feedback failed to send: ", JSON.stringify(response))
    if (response.message === 'No connection') {
        SignalsModule.Signals.feedbackResult("No Connection")
    } else if ((response.message === 'Response not valid') && (response.status !== undefined)) {
        SignalsModule.Signals.feedbackResult("Feedback service error: " + response.status)
    } else {
        SignalsModule.Signals.feedbackResult("Feedback service error")
    }
}

function getNextId(){
   return Rest.getNextRequestId();
}
