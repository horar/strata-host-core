.pragma library

.import "restclient.js" as Rest
.import "utilities.js" as Utility
.import tech.strata.logger 1.0 as LoggerModule

/*
  Send Feedback information to server
*/

var signals = Utility.createObject("qrc:/partial-views/general/Signals.qml", null)
function feedbackInfo(feedback_info){
    let headers = {
        "app": "strata",
        "version": Rest.versionNumber(),
    }

    var data = {"email": feedback_info.email, "name": feedback_info.name, "comment" : feedback_info.comment };
    Rest.xhr("post", "feedbacks", data, feedback_result,feedback_error, signals, headers);
}


function feedback_result(response) {
    console.log(LoggerModule.Logger.devStudioFeedbackCategory, "Feedback successfully sent")
        signals.feedbackResult("Feedback successfully sent")
}

function feedback_error(response) {
    console.log(LoggerModule.Logger.devStudioFeedbackCategory, "Feedback failed to send")
    if(response.message === 'No connection'){
        signals.feedbackResult("No Connection")
    } else {
        signals.feedbackResult("Feedback service error")
    }
}
