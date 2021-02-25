import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebView 1.1
import strata.example.PKCEGenerator 1.0
import strata.example.UrlQuery 1.0
import strata.example.Url 1.0
import "rest.js" as Rest
Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Okta Login/Signup WebView")
    property string clientId: "0oa8akdtteXGDfRz61d6"
    property string scope: "openid+profile"
    property string redirectUri: "www.onsemi.com"
    property string codeChallengeMethod: "S256"
    property string authServerVersion: "v1"
    property string tokenEndpoint: "/" + authServerVersion + "/token"
    property string userInfoEndpoint: "/" + authServerVersion + "/userinfo"
    property string authorizationServerUrl: "https://onsemi.oktapreview.com/oauth2"
    property string webviewURL: ""

    function buildOAuthUrl(clientId, scope, redirectUri, codeChallengeMethod, codeChallenge){
        webviewURL = authorizationServerUrl +"/" + authServerVersion + "/" +
                                 "authorize?client_id=" + clientId +
                                 "&response_type=code" +
                                 "&scope=" + scope +
                                 "&redirect_uri=https://" + redirectUri +
                                 "&state=state0" +
                                 "&code_challenge_method=" + codeChallengeMethod +
                                 "&code_challenge=" + codeChallenge
    }
    function authenticate(authorization_code){
        let request_body = "grant_type=authorization_code"+
            "&client_id=" + clientId +
            "&code=" + authorization_code +
            "&code_verifier=" + pkce.code_verifier +
            "&redirect_uri=https://" + redirectUri
        let headers = {
            "Content-Type": "application/x-www-form-urlencoded"
        }

        Rest.xhr("POST", authorizationServerUrl + tokenEndpoint, headers, request_body,
            function(response){
                try{
                    console.log("Tokens:", response)
                    let tokens = JSON.parse(response)
                    getUserInfo(tokens["access_token"])
                }catch(e){
                    console.error(e)
                }
            },
            function(err){
                console.error(err)
            },
        );
    }

    function getUserInfo(access_token){
        let headers = {
            "Accept": "application/json",
            "Authorization": "Bearer " + access_token
        }
        Rest.xhr("GET", authorizationServerUrl + userInfoEndpoint, headers, '',
            function(response){
                console.log("User Info:", response)
            },
            function(err){
                console.error(err)
            },
        );
    }

    PKCEGenerator{
        id: pkce
    }
    UrlQuery{
        id: urlQuery
    }
    Url{
        id:urlHelper
    }

    Component.onCompleted: {
        buildOAuthUrl(clientId, scope, redirectUri, codeChallengeMethod, pkce.code_challenge)
        console.log("Okta webview URL:", webviewURL)
    }

    WebView {
        id: webView
        anchors.fill: parent
        url: webviewURL
        onLoadingChanged: {
            if (loadRequest.errorString){
                console.error(loadRequest.errorString);
            }

            if(urlHelper.getHost(url) === redirectUri){
                let authorization_code = urlQuery.queryItemValue(url, "code")
                authenticate(authorization_code)
            }

        }
    }
}
