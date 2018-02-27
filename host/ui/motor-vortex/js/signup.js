function register() {
    var data = {
        firstname:firstname.text,
        lastName:lastname.text,
        username:username.text,
        password:password.text,
        admin:1
    }

    Rest.xhr("post","signup",data,
             function(res){
                 console.log("in response")
                 console.log(JSON.stringify(res))
                 singupErrorMsgText.text = ""
             },
             function(err){
                 console.log(err)
                 singupErrorMsgText.text = err.message
                 console.log("in error")
                 console.log(JSON.stringify(err))
             })
}
