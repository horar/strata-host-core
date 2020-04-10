import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0


Rectangle {
    id: root

    onVisibleChanged: {
        resetThermostatBar.start()
    }

    Text{
        id:title
        anchors.top:parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        text:"sensor"
        font.pixelSize: 72
    }

//    Image{
//            source: "qrc:/views/meshNetwork/images/sensorDemo.png"
//            height:parent.height *.4
//            anchors.centerIn: parent
//            fillMode: Image.PreserveAspectFit
//            mipmap:true
//        }

    Button{
        id:getTemperatureButton
        anchors.left:parent.left
        anchors.leftMargin: parent.width * .2
        anchors.verticalCenter: parent.verticalCenter
        text:"get temperature"

        contentItem: Text {
                text: getTemperatureButton.text
                font.pixelSize: 24
                opacity: enabled ? 1.0 : 0.3
                color: "black"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                color: getTemperatureButton.down ? "lightgrey" : "transparent"
                border.color: "black"
                border.width: 2
                radius: 10
            }

            onClicked: {
                platformInterface.demo_click.update("sensor","get_sensor_data","on")
                growThermostatBar.start()
            }
    }

    Text{
        id:temperatureText
        anchors.top: getTemperatureButton.bottom
        anchors.topMargin: 40
        anchors.left: getTemperatureButton.left
        font.pixelSize: 36
        text:"current temperature is"
        visible:false

        property var sensorData: platformInterface.demo_click_notification
        onSensorDataChanged:{
            if (platformInterface.demo_click_notification.demo === "sensor")
                if (platformInterface.demo_click_notification.button === "get_sensor_data"){
                    temperatureText.visible = true
                    temperatureText.text += latformInterface.demo_click_notification.value + "°C"
                }

        }
    }

    Image{
        id:arrowImage
        anchors.left:getTemperatureButton.right
        anchors.right:sensorImage.left
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/views/meshNetwork/images/leftArrow.svg"
        height:25
        fillMode: Image.PreserveAspectFit
        mipmap:true
    }

    Image{
        id:sensorImage
        anchors.right:parent.right
        anchors.rightMargin:parent.width*.1
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/views/meshNetwork/images/sensorIcon.svg"
        height:400
        fillMode: Image.PreserveAspectFit
        mipmap:true

        Rectangle{
            id:thermostatBar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -30
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 100
            width:25
            height:10
            color:"#f5a623"
        }
    }

    PropertyAnimation{
        id:growThermostatBar
        target: thermostatBar;
        property: "height";
        to: 225;
        duration: 1000
        running:false
    }

    PropertyAnimation{
        id:resetThermostatBar
        target: thermostatBar;
        property: "height";
        to: 10;
        duration: 0
        running:false
    }

    Button{
        id:resetButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 20
        text:"reconfigure"

        contentItem: Text {
                text: resetButton.text
                font.pixelSize: 20
                opacity: enabled ? 1.0 : 0.3
                color: "grey"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                color: resetButton.down ? "lightgrey" : "transparent"
                border.color: "grey"
                border.width: 2
                radius: 10
            }

            onClicked: {
                platformInterface.set_demo.update("sensor")
                root.resetUI()
            }
    }

    function resetUI(){
        resetThermostatBar.start()
    }
}
