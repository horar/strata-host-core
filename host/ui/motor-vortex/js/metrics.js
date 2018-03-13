.pragma library
.import "restclient.js" as Rest

/*
    Metrics
    Object will be a time keeper for user dwell time and hits.
*/

// Global variables
var timeSinceLastViewChanged = 0.0
var currentTabIndex = 0
var currentTabName = ''
var context = null;

/*
  Init to retrieve context info from Navigation controller.
  ex. User_id
*/
function init(context){
    this.context = context;
    timeSinceLastViewChanged = new Date();

}

/*
    Iterate through qml objects tree and invoke add custom function to listen on events
    of the child TabBar control
*/
function injectEventToTree(obj) {

    // inject custom function to all children that has onCurrentIndexChanged event
    if(qmltypeof(obj,"QQuickTabBar")){
        Object.defineProperty(obj, 'onCurrentIndexChangedlListenerFunction', { value: createListenerFunction(obj) })
        obj.onCurrentIndexChanged.connect(obj.onCurrentIndexChangedlListenerFunction);

        //TODO: Add a listener to get tababr button's name at index 0

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

// Return a listener function that will be invoked on the tabbar change event
function createListenerFunction(object) {
    return function() { onCurrentIndexChange(object, arguments) }
}

// Return a tabBarCompleted function
function onTabBarCompletedListenerFunction(object) {

    return function() { tabBarCompleted(object, arguments) }
}

// Given qml object and name, it check whether name is matching object type
function qmltypeof(obj, className) {
  var str = obj.toString();
  return str.indexOf(className + "(") === 0 || str.indexOf(className + "_QML") === 0;
}

/*
  This function is used as a listener function on the injected tabbar child to handle
  dwell time and hit count at the TabBar view level.
*/
function onCurrentIndexChange(object,args){
    console.log("onCurrentIndexChanged:", object,"index:",object.currentIndex,"tab name:",object.currentItem.text,JSON.stringify(this.context))
    var tabName = object.contentChildren[currentTabIndex].text
    var platfromName = context.platform_name
    sendMetricsToCloud(platfromName +' '+tabName)

    currentTabIndex = object.currentIndex;
    currentTabName = object.currentItem.text
}

/*
  This function is used as a listener function on the injected tabbar child to handle
  the start time at the TabBar view level
*/
function tabBarCompleted(object,args){
    currentTabName = object.currentItem.text
}

/*
  Restart timer
*/
function restartTimer(){
    timeSinceLastViewChanged = new Date();
}

/*
  Get overall dwell time by date subtraction
*/
function getTimeElapsed(){
    var oldDate = timeSinceLastViewChanged;
    var newDate = new Date()
    return (newDate.getTime() - oldDate.getTime())/1000.0;
}

/*
  getCurrentTab
*/
function getCurrentTab(){
    return currentTabName
}

/*
  Sends usage data to cloud server
*/
function sendMetricsToCloud(page_name){
    var data = {
        time:timeSinceLastViewChanged,
        howLong:getTimeElapsed(),
        page: page_name
    };
    console.log(JSON.stringify(data))

    Rest.xhr("post","metrics",data,function(res){
        console.log("Post response: ",JSON.stringify(res))
    },function(err){
        console.log("Post error: ", JSON.stringify(err))
    });
    timeSinceLastViewChanged = new Date();
}
