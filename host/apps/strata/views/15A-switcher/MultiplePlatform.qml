import QtQuick 2.0
import "qrc:/js/navigation_control.js" as NavigationControl

Item {

    property int class_id: NavigationControl.context.class_id
    /*
      properties that changes for different platform using same UI
    */
    property bool modeVisible: false
    property bool holder3231: false
    property var listOfOutputValue;
    property string warningVinLable: "2.5V"
    property string partNumber:  "NCP3235"
    property string title: "<b>High Current Sync Buck Converter</b>"

    function check_class_id ()
    {
        if(class_id == 207) {
            modeVisible = true
            holder3231 = true
            partNumber = " <b> NCP3235 </b>"
            listOfOutputValue = [">20A", "17.5A", "10A"]
            title = "<b>High Current Sync Buck Converter</b>"
        }
        if(class_id == 219) {
            modeVisible = false
            holder3231 = true
            partNumber = " <b> NCP3232 </b>"
            listOfOutputValue = [">20A", "17.5A", "10A"]
            title = "<b>High Current Sync Buck Converter</b>"
        }

        if(class_id == 220) {
            modeVisible = false
            holder3231 = true
            partNumber = " <b> NCP3231 </b>"
            listOfOutputValue = [">30A", "27A", "10A"]
            title = "<b>High Current Sync Buck Converter</b>"
        }
    }

}
