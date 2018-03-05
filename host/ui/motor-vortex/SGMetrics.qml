import QtQuick 2.0
import "js/restclient.js" as Rest
import "js/navigation_control.js" as NavigationControl
Item {

    property var seconds: 0.0
    property var timeSinceLastIndexChange:0.0 ;
    property var currentTab: 0

    Timer {
        id:counter
        interval: 1000; running: false; repeat: true
        onTriggered: function(){
            seconds +=1
        }
    }

    Component.onCompleted: function(e){

        //TODO: check if content or control
        this.childrenSignal.connect(onCurrentIndexChange)

        //this.childrenSignal.connect(onControlViewChange)
        timeSinceLastIndexChange = new Date();

        //counter.start()

    }
    signal childrenSignal(var sender, var arguments)

    function onCurrentIndexChange(object,args){
        console.log("onCurrentIndexChanged:", object,"index:",object.currentIndex,"tab name:",object.currentItem.text)

        var tabName = object.currentItem.text
        sendMetricsToCloud(tabName)

        currentTab = object.currentIndex;
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
    function sendMetricsToCloud(page){

        counter.restart();

        var data = {
            time:timeSinceLastIndexChange,
            howLong:String(seconds),
            page: page
        };

        console.log(JSON.stringify(data))

        Rest.xhr("post","metrics",data,function(res){
            console.log(res)
        },function(err){
            console.log(err)
        });

        timeSinceLastIndexChange = new Date();
        seconds= 0.0


    }
}
