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
    }
}
