.import "restclient.js" as Rest

.import Strata.Logger 1.0 as LoggerModule

var confirmPopup = null

/*
  Send Feedback information to server
*/
function feedbackInfo(feedback_info, success, error){
    var data = {"name":feedback_info.name ,"email": feedback_info.email, "company":feedback_info.company, "comment" : feedback_info.comment };
    console.log("Feedback body:", JSON.stringify(data));
    Rest.xhr("post", "feedbacks", data, success , error, null);
}

function onSuccess(response)
{
    console.log(LoggerModule.Logger.devStudioFeedbackCategory, "response: ", JSON.stringify(response));

}
function onError(response)
{
    console.log(LoggerModule.Logger.devStudioFeedbackCategory, "error response: ", JSON.stringify(response));
}

