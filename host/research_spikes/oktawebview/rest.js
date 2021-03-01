.pragma library

function xhr(method, url, headers, data, callback, error) {
    var xhr = new XMLHttpRequest();

    xhr.onreadystatechange = function() {
        if ( xhr.readyState === 4 && xhr.status < 300) {
            callback( xhr.responseText );
        }
        if(xhr.readyState === 4 && xhr.status >= 300){
            console.log("response status: ", xhr.status)
            console.log("response body: ", xhr.responseText)
            error("response status code: - body:" + xhr.status, xhr.responseText)
        }
    };

    xhr.onerror = error

    xhr.open( method, url, true);

    if (headers) {
        for (var header in headers) {
            if (headers.hasOwnProperty(header)) {
                xhr.setRequestHeader(header, headers[header])
            }
        }
    }

    xhr.send(data);

}
