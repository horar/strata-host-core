.pragma library
.import "restclient.js" as Rest
/*
    Metrics Code
*/

//metrics variables
var timeSinceLastViewChanged = 0.0
var currentTabIndex = 0
var currentTabName = ''
var context = null;

function init(context){
    this.context = context;
    timeSinceLastViewChanged = new Date();

}

//Iterate through qml objects tree and invoke add custom function to listen on events
function injectEventToTree(obj) {

    // inject custom function to all children that has onCurrentIndexChanged event
    if(qmltypeof(obj,"QQuickTabBar")){
        Object.defineProperty(obj, 'onCurrentIndexChangedlListenerFunction', { value: createListenerFunction(obj) })
        obj.onCurrentIndexChanged.connect(obj.onCurrentIndexChangedlListenerFunction);

        //TODO: Add a listener to get tababr button's name at index 0
        //Object.defineProperty(obj, 'onCompletedListenerFunction', { value: onTabBarCompletedListenerFunction(obj) })
        //obj.Component.onCompleted.connect(obj.onCompletedListenerFunction);

    }

    if (obj.children) {

        for (var i = 0; i < obj.children.length; i++) {
            injectEventToTree(obj.children[i])
        }
        if(obj.children.length > 100){
            console.log("WARNING: QML object children exceeds 100.")
        }
    }
}

// return a listener function that will be invoked on the tabbar change event
function createListenerFunction(object) {
    return function() { onCurrentIndexChange(object, arguments) }
}
function onTabBarCompletedListenerFunction(object) {

    return function() { tabBarCompleted(object, arguments) }
}
// given qml object and name, it check whether name is matching object type
function qmltypeof(obj, className) {
  var str = obj.toString();
  return str.indexOf(className + "(") === 0 || str.indexOf(className + "_QML") === 0;
}

function onCurrentIndexChange(object,args){
    console.log("onCurrentIndexChanged:", object,"index:",object.currentIndex,"tab name:",object.currentItem.text,JSON.stringify(this.context))
    var tabName = object.contentChildren[currentTabIndex].text
    var platfromName = context.platform_name
    sendMetricsToCloud(platfromName +' '+tabName)

    currentTabIndex = object.currentIndex;
    currentTabName = object.currentItem.text
}
function tabBarCompleted(object,args){
    currentTabName = object.currentItem.text
}
function restartTimer(){
    timeSinceLastViewChanged = new Date();
}
function getTimeElapsed(){
    var oldDate = timeSinceLastViewChanged;
    var newDate = new Date()
    return (newDate.getTime() - oldDate.getTime())/1000.0;
}

function getCurrentTab(){
    return currentTabName
}

function sendMetricsToCloud(page){
    var data = {
        time:timeSinceLastViewChanged,
        howLong:getTimeElapsed(),
        page: page
    };
    console.log(JSON.stringify(data))

    Rest.xhr("post","metrics",data,function(res){
        console.log(res)
    },function(err){
        console.log(err)
    });
    timeSinceLastViewChanged = new Date();
}
