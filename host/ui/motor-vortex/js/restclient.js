var url = "http://localhost:8081/";

var xhr = function(method, endpoint, data, callback,errorCallback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
            if ( xhr.readyState === 4 && xhr.status >= 200 && xhr.status < 300) {
                console.log(xhr.responseText)
                callback( JSON.parse(xhr.responseText) );
            }
            else if(xhr.status >= 400){
                if(errorCallback !== undefined){
                    errorCallback(JSON.parse(xhr.responseText));
                }
            }
            console.log("status")
            console.log(xhr.status)
        };
        var fullUrl = url + endpoint;
        xhr.open( method, fullUrl );
        // This must be after open
        xhr.setRequestHeader("Content-Type","application/json");
        xhr.send(JSON.stringify(data));
}
