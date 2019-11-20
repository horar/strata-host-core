import QtQuick 2.12

Item {
    id: sensorRowRoot
    width: sensorRow.width

    signal showAmbientLightValue()
    signal hideAmbientLightValue()
    signal showBatteryCharge()
    signal hideBatteryCharge()
    signal showTemperature()
    signal hideTemperature()
    signal showSignalStrength()
    signal hideSignalStrength()

    Row{
        id:sensorRow
        spacing: 20.0     //causes a crash?

        Image{
            id:signalStrengthImage
            source:"../images/wifiIcon.svg"
            fillMode: Image.PreserveAspectFit
            height:parent.height
            mipmap:true
            opacity:.2

            MouseArea {
                id: signalStrengthMouseArea
                anchors.fill: parent


                onPressed: {
                    signalStrengthImage.opacity = .75;
                    //send a signal to show current ambient light reading
                    sensorRowRoot.showSignalStrength();
                }
                onReleased: {
                    signalStrengthImage.opacity = .2;
                    //send a signal to show current ambient light reading
                    sensorRowRoot.hideSignalStrength();
                }

            }
        }

        Image{
            id:ambientLightImage
            source:"../images/ambientLightIcon.svg"
            fillMode: Image.PreserveAspectFit
            mipmap:true
            opacity:.2

            MouseArea {
                id: ambientLightMouseArea
                anchors.fill: parent


                onPressed: {
                    ambientLightImage.opacity = .75;
                    //send a signal to show current ambient light reading
                    sensorRowRoot.showAmbientLightValue();
                }
                onReleased: {
                    ambientLightImage.opacity = .2;
                    //send a signal to show current ambient light reading
                    sensorRowRoot.hideAmbientLightValue();
                }

            }
        }

        Image{
            id:batteryChargeImage
            source:"../images/batteryChargeIcon.svg"
            height:parent.height
            fillMode: Image.PreserveAspectFit
            mipmap:true
            opacity:.2

            MouseArea {
                id: batteryChargeMouseArea
                anchors.fill: parent


                onPressed: {
                    batteryChargeImage.opacity = .75
                    sensorRowRoot.showBatteryCharge();
                }
                onReleased: {
                    batteryChargeImage.opacity = .2
                    sensorRowRoot.hideBatteryCharge();
                }
            }
        }

        Image{
            id:temperatureImage
            source:"../images/temperatureIcon.svg"
            fillMode: Image.PreserveAspectFit
            mipmap:true
            opacity:.2

            MouseArea {
                id: temperatureMouseArea
                anchors.fill: parent


                onPressed: {
                    temperatureImage.opacity = .75
                    sensorRowRoot.showTemperature();
                }
                onReleased: {
                    temperatureImage.opacity = .2
                    sensorRowRoot.hideTemperature();
                }
            }
        }


    }

}
