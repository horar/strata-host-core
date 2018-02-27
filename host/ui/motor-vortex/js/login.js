.import "restclient.js" as Rest
.import "navigation_control.js" as NavigationControl

function onInputChange() {
    // clear error
    errorMsgText.text = ""
}
function login(login_info){
    var data = {"username":login_info.user,"password":login_info.password};
    Rest.xhr("post","login",data,
             login_result)
}

function login_result(response)
{
    console.log("Result = ", resp)
}
