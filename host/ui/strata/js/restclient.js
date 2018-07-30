.pragma library
var url = "http://18.222.75.160/";
// jwt will be set after successful login
var jwt = '';
var xhr = function(method, endpoint, data, callback,errorCallback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
            if ( xhr.readyState === 4 && xhr.status >= 200 && xhr.status < 300) {
                console.log(xhr.responseText)
                callback( JSON.parse(xhr.responseText) );
            }
            else if(xhr.readyState === 4 && xhr.status >= 400){
                if(errorCallback !== undefined){
                    errorCallback(JSON.parse(xhr.responseText));
                }
            }
            // No connection to db. For some reason we get readyState as 4.
            else if(xhr.readyState === 4 && !xhr.hasOwnProperty("status") ){
                errorCallback({status: "no connection"})
            }
        };
        var fullUrl = url + endpoint;
        xhr.open( method, fullUrl );
        // This must be after open
        xhr.setRequestHeader("Content-Type","application/json");
        // Set JWT in the requst header
        console.log("JWT", jwt)
        xhr.setRequestHeader("x-access-token",jwt);
        xhr.send(JSON.stringify(data));
}
