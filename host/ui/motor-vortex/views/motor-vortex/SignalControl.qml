import QtQuick 2.0

Item {
        id: control
        // add all syncrhonized controls here
        property int motorSpeedSliderValue: 1500

        onMotorSpeedSliderValueChanged: {
            platformInterface.motor_speed.update(motorSpeedSliderValue)
        }

        property int rampRateSliderValue: 3

        onRampRateSliderValueChanged: {
             platformInterface.set_ramp_rate.update(rampRateSliderValue)
        }

        property int phaseAngle : 15

        onPhaseAngleChanged: {
            platformInterface.set_phase_angle.update(phaseAngle)
        }

        property int ledSlider: 128

        onLedSliderChanged: {
            console.log("in signal control")
        }

        property int singleLEDSlider :  0





}
