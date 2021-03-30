import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebView 1.1

import strata.example.OktaWebviewCpp 1.0

Window {
    id: root
    visible: true

    width: 640
    height: 480
    title: qsTr("Okta Login/Signup WebView")

    property string webviewURL: ""
    property string redirectUri: "www.onsemi.com"

    Component.onCompleted: {
        webviewURL = oktaWebviewCpp.buildOAuthUrl()
    }

    WebView {
        id: webView
        anchors.fill: parent
        url: webviewURL
        onLoadingChanged: {
            if (loadRequest.errorString){
                console.error(loadRequest.errorString);
            }

            if (oktaWebviewCpp.getHost(url) === redirectUri) {
                let authorizationCode = oktaWebviewCpp.queryItemValue(url, "code")
                let accessToken = oktaWebviewCpp.authenticate(authorizationCode)
                let userInfo = oktaWebviewCpp.getUserInfo(accessToken)
                console.log("User Info:", userInfo)
            }
        }
    }
}
