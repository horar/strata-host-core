import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3


Window {
    id: window
    visible: true
    width: 1200
    height: 900
    title: qsTr("mesh demo")

    property int objectWidth: 200
    property int objectHeight: 200
    property int highestZLevel: 1
    signal changeObjectSize(int objectSize);

    property real backgroundCircleRadius: window.width/4
    property int meshObjectCount:0
    property variant meshObjects

    Rectangle{
        id:backgroundCircle
        objectName:"backgroundCircle"
        anchors.centerIn: parent
        width:backgroundCircleRadius * 2
        height:backgroundCircleRadius * 2
        color:"grey"
        opacity:.1
        radius:backgroundCircleRadius

        Component.onCompleted: {
            //console.log("backroundCircleRadius is ",backgroundCircleRadius)
        }
    }

//    Item {
//        id:dropArea
//        width: window.objectWidth;
//        height: window.objectHeight


//        Rectangle{
//            anchors.fill:parent
//            color:"pink"
//            opacity:.1
//        }

        MeshObject{
            id:provisioner
            objectName:"provisioner"
            provisionerNode: true
            anchors.horizontalCenter: backgroundCircle.horizontalCenter
            //anchors.horizontalCenterOffset: Math.cos(0) * backgroundCircleRadius
            anchors.verticalCenter: backgroundCircle.verticalCenter
            //anchors.verticalCenterOffset: Math.sin(0) * backgroundCircleRadius

        }
 //   }

    Button{
        id:createNewObjectButton
        objectName:"newObjectButton"
        text:"add object"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.rightMargin: 50



        onClicked:{
            meshObjectCount++;
            var  horizCenter = backgroundCircle.horizontalCenter
            var  horizOffset=  Math.cos(Math.PI*(2/meshObjectCount)) * backgroundCircleRadius
            var  verticalCenter =  backgroundCircle.verticalCenter
            var  verticalOffset = Math.sin(Math.PI*(2/meshObjectCount)) * backgroundCircleRadius
//            console.log("item count=",meshObjectCount);
//            console.log("horizontal offset=",horizOffset);
//            console.log("vertical offset=",verticalOffset);

//            var colorArray = ['red', 'green', 'blue', 'yellow', 'purple'];
//            var colorIndex = ((Math.random() * 4) ).toFixed(0);
//            var objectColor = colorArray[colorIndex];
            var objectColor = "green"

            var newComponent = Qt.createComponent("MeshObject.qml");

            var sprite = newComponent.createObject(window, {"anchors.horizontalCenter": horizCenter,
                                                             "anchors.horizontalCenterOffset": horizOffset,
                                                             "anchors.verticalCenter":verticalCenter,
                                                             "anchors.verticalCenterOffset":verticalOffset,
                                                              objectName: "controller" + meshObjectCount.toString(),
                                                              objectNumber: meshObjectCount.toString(),
                                                              color:objectColor});
            console.log("objectNumber=",sprite.objectNumber);
            console.log("there are now",window.contentItem.children.length,"items in the window");
            //move the other sensors so they're all spaced evenly
            respaceSensors();
            window.highestZLevel++;
        }
    }

    function respaceSensors(){
        //figure out how many objects we have (meshObjectCount)
        //use that to calculate the angle that should be between objects (2PI / meshObjectCount)
        var anglePerObject= (Math.PI * 2) / meshObjectCount;

        //iterate over the window's children. If the object isn't the background circle or provisioner
        for (var i = 0; i < window.contentItem.children.length; i++)
        {
            console.log("item "+i);
            console.log(window.contentItem.children[i].objectName);
            if (window.contentItem.children[i].objectName.startsWith("controller")){
                //then change the object's horizontal and vertical center offsets appropriately
                var  horizOffset=  Math.cos(anglePerObject * i) * backgroundCircleRadius
                var  verticalOffset = Math.sin(anglePerObject *i) * backgroundCircleRadius
                //window.contentItem.children[i].anchors.horizontalCenterOffset = 0;
                //window.contentItem.children[i].anchors.verticalCenterOffset = 0;
                window.contentItem.children[i].anchors.horizontalCenterOffset = horizOffset;
                window.contentItem.children[i].anchors.verticalCenterOffset = verticalOffset;
                //console.log("horizontal offset=", window.contentItem.children[i].anchors.horizontalCenterOffset, "should be",horizOffset);
                //console.log("vertical offset=", window.contentItem.children[i].anchors.verticalCenterOffset, "should be",verticalOffset);
            }
        }

    }


    Slider{
        id:objectSizeSlider
        objectName:"sizeSlider"
        anchors.top:createNewObjectButton.bottom
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 50

        from:100
        to:200
        onMoved:{
           window.changeObjectSize(objectSizeSlider.value);
        }
    }
    Label{
        id: objectSizeLabel
        objectName:"object size label"
        anchors.right:objectSizeSlider.left
        anchors.verticalCenter: objectSizeSlider.verticalCenter
        anchors.rightMargin: 10

        text:"size"

    }

    SensorRow{
        id:sensorRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 50
        height:50
    }


}
