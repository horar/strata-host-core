import QtQuick 2.0
import "qrc:/js/navigation_control.js" as NavigationControl

Item{

    property int class_id: NavigationControl.context.class_id

    /*
      properties that changes for different platform using same UI
    */
    property bool ecoVisiable: false
    property string warningVinLable: "2.5V"
    property string partNumber:  " "
    property string title: "<b>Low Noise and High PSRR Linear Regulator</b>"
    property bool showDecimal;

    function check_class_id ()
    {
        if(class_id === 214) {
            ecoVisiable = true
            title =  "<b>Low Noise and High PSRR Linear Regulator</b> "
            partNumber = " <b> NCV8163/NCP163 </b>"
            warningVinLable = "2.25V"
            showDecimal = false
        }
        else if(class_id === 206) {
            ecoVisiable = false
            partNumber =  "<b> NCV8163/NCP163 </b>"
            title =  "<b>Low Noise and High PSRR Linear Regulator</b> "
            warningVinLable = "2.25V"
            showDecimal = false
        }
        else if(class_id === 210) {
            partNumber = "<b> NCP110 </b>"
            title = "<b> Low Noise and High PSRR Linear Regulator </b>"
            ecoVisiable = false
            warningVinLable = "1.1V"
            showDecimal = false
        }
        else if(class_id === 211) {
            ecoVisiable = false
            partNumber = "<b> NCP115 </b>"
            title = "<b> High PSRR Linear Regulator </b>"
            warningVinLable = "1.7V"
            showDecimal = false
        }
        else if(class_id === 212) {
            ecoVisiable = false
            partNumber = " <b> NCV8170/NCP170 </b>"
            title = "<b> Low Iq CMOS Linear Regulator </b>"
            warningVinLable = "2.25V"
            showDecimal = false

        }
        else if(class_id === 217) {
            ecoVisiable = true
            partNumber = "<b> NCP171 </b>"
            title = "<b> Low Iq Dual Power Mode Linear Regulator </b>"
            warningVinLable = "1.7V"
            showDecimal = true
        }
        else  {
            console.log("unknown")
        }
    }
}
