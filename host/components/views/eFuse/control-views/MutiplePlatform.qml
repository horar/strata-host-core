import QtQuick 2.0
import "qrc:/js/navigation_control.js" as NavigationControl

Item {

    property string class_id: NavigationControl.context.class_id
    property string partNumber:  "eFuse"


    function check_class_id(){
        if(class_id === "227"){
            partNumber =  "NIS5020 eFuse"
        }
        else if(class_id === "228") {
            partNumber = "NIS5820 eFuse"

        }
        else if(class_id === "229") {
            partNumber = "NIS5132 eFuse"
        }
        else if(class_id === "230") {
            console.log("s")
            partNumber = "NIS5232 eFuse"
        }
        else {
            console.log("platform undefined")
        }
    }

}
