import QtQuick 2.0
import "js/restclient.js" as Rest
import "js/navigation_control.js" as NavigationControl
Item {

    property var seconds: 0.0
    property var timeSinceLastViewChanged:0.0 ;
    property var currentTab: 0
    property var currentTabName: ''

    Timer {
        id:counter
        interval: 1000; running: false; repeat: true
        onTriggered: function(){
            seconds +=1
        }
    }

    Component.onCompleted: function(e){
        this.childrenSignal.connect(onCurrentIndexChange)
        this.tabBarOnCompletedSignal.connect(tabBarCompleted)
        timeSinceLastViewChanged = new Date();
    }

    signal childrenSignal(var sender, var arguments)

    signal tabBarOnCompletedSignal(var sender, var arguments)

    function onCurrentIndexChange(object,args){
        console.log("onCurrentIndexChanged:", object,"index:",object.currentIndex,"tab name:",object.currentItem.text)

        var tabName = object.contentChildren[currentTab].text
        var platfromName = NavigationControl.context.platform_name
        sendMetricsToCloud(platfromName +' '+tabName)

        currentTab = object.currentIndex;
        currentTabName = object.currentItem.text
    }
    function tabBarCompleted(object,args){
        console.log("I am here --------------------------------------",object.currentItem.text,object.currentItem)
        currentTabName = object.currentItem.text
    }

    function startCounter(){
        counter.start()
    }
    function stopCounter(){
        counter.stop()
    }
    function restartCounter(){
        counter.restart()
        seconds = 0.0
    }
    function getCurrentTab(){
        return currentTabName
    }

    function sendMetricsToCloud(page){

        counter.restart();

        var data = {
            time:timeSinceLastViewChanged,
            howLong:String(seconds),
            page: page
        };

        console.log(JSON.stringify(data))

        Rest.xhr("post","metrics",data,function(res){
            console.log(res)
        },function(err){
            console.log(err)
        });

        timeSinceLastViewChanged = new Date();
        seconds= 0.0


    }
}
