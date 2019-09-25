.import "restclient.js" as Rest

.import tech.strata.logger 1.0 as LoggerModule

/*
  Send Feedback information to server
*/
function feedbackInfo(feedback_info, success, error){
    var data = {"email": feedback_info.email, "name": feedback_info.name, "company": feedback_info.company, "comment" : feedback_info.comment };
    console.log(LoggerModule.Logger.devStudioFeedbackCategory, "Feedback body:", JSON.stringify(data));
    Rest.xhr("post", "feedbacks", data, success, error, null);
}
