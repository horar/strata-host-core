import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

import tech.spyglass.DocumentManager 1.0
import QtWebView 1.1

Rectangle {
    id: container
    // Anchors are not supported on a SlideView ( Parent )

    WebView {
        id: webview
        anchors {
            fill: container
        }
        url: "qrc:/views/motor-vortex/InteractiveBlockDiagramDemo.html"
    }

//    Text {
//        id: text
//        textFormat: Text.PlainText
//        Component.onCompleted: {
//            container.readTextFile("http://www.onsemi.com/PowerSolutions/responsiveAppDiagram.do?appId=152&parentAppId=15068")
//        }
//    }

//    function readTextFile(fileUrl){
//        var xhr = new XMLHttpRequest;
//        xhr.open("GET", fileUrl); // set Method and File
//        xhr.onreadystatechange = function () {
//            if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
//                var response = xhr.responseText;

//                text.text = response
//            }
//        }
//        xhr.send(); // begin the request
//    }
}
