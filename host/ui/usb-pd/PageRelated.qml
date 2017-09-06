import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtWebView 1.1

Item {

    WebView {
        id: pdfViewer
        anchors { fill: parent }

        url: "http://www.onsemi.com/PowerSolutions/home.do"
        onLoadingChanged: {
            if (loadRequest.errorString)
                console.error(loadRequest.errorString);
        }
    }
}

