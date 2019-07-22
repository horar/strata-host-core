import QtQuick 2.0
import "qrc:/js/navigation_control.js" as NavigationControl

Item {

    property string class_id: NavigationControl.context.class_id
    property string partNumber:  "eFuse"
    property var slewModel: [ "1ms", "5ms" ]


    function check_class_id(){
        if(class_id === "227"){
            partNumber =  "NIS5020 eFuse"
        }
        else if(class_id === "228") {
            partNumber = "NIS5820 eFuse"

        }
        else if(class_id === "229") {
            partNumber = "NIS5132 eFuse"
            slewModel = ["1.5mA", "8mA"]
        }
        else if(class_id === "230") {
            partNumber = "NIS5232 eFuse"
            slewModel = ["1.5mA", "8mA"]
        }
        else {
            console.log("platform undefined")
        }
    }

}
