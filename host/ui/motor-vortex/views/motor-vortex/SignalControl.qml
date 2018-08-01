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

        property real singleLEDSlider :  0

        property int ledPulseSlider: 150

       onLedPulseSliderChanged:  {
            platformInterface.set_blink0_frequency.update(ledPulseSlider)
        }

       property bool driveModePseudoSinusoidal: false

       onDriveModePseudoSinusoidalChanged: {
           console.log("in the drive mode pse")
          platformInterface.set_drive_mode.update(1)
       }

       property bool driveModePseudoTrapezoidal: true

       onDriveModePseudoTrapezoidalChanged: {
           console.log("in the drive mode trap")
           platformInterface.set_drive_mode.update(0)
       }

       property bool motorState: true

       onMotorStateChanged: {
            console.log("in motor state")
           if(motorState == true) {
                platformInterface.set_motor_on_off.update(0)
           }
           else  {
                platformInterface.motor_speed.update(motorSpeedSliderValue);
               platformInterface.set_motor_on_off.update(1)
           }

       }




}
