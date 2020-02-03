import QtQuick 2.0
import "qrc:/js/navigation_control.js" as NavigationControl

Item {

    property string class_id: NavigationControl.context.class_id
    /*
      properties that changes for different platform using same UI
    */
    property bool modeVisible: false
    property bool holder3231: false
    property var listOfOutputValue;
    property string warningVinLable: "2.5V"
    property string partNumber:  "<b> FAN65005A </b>"
    property string title: "<b>5A,50V Switching Regultor</b>"



    function check_class_id ()
    {
        console.log(class_id)
        if(class_id === "241") {
            partNumber = "FAN65005A "
        }

//        if(class_id === "242") {
//            partNumber = "FAN65008B"
//        }

//        if(class_id == 24) {
//            partNumber = "FAN65008B"
//        }


        //        if(class_id == 219) {
        //            modeVisible = false
        //            holder3231 = false
        //            partNumber = " <b> NCP3232 </b>"
        //            listOfOutputValue = [">20A", "17.5A", "10A"]
        //            title = "<b>High Current Sync Buck Converter</b>"
        //            maxValue = 60
        //            stepValue = 6
        //            classid3235 = true
        //        }

        //        if(class_id == 220) {
        //            modeVisible = false
        //            holder3231 = false
        //            partNumber = " <b> NCP3231 </b>"
        //            listOfOutputValue = [">30A", "27A", "10A"]
        //            title = "<b>High Current Sync Buck Converter</b>"
        //            maxValue = 100
        //            stepValue = 10
        //            classid3235 = true

        //        }
    }

}
