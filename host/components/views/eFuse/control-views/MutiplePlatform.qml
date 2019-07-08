import QtQuick 2.0
import "qrc:/js/navigation_control.js" as NavigationControl

Item {

    property string class_id: NavigationControl.context.class_id
    property string partNumber:  "NIS5020 eFuse"


    function check_class_id(){
        if(class_id === 227){
            partNumber =  "NIS5020 eFuse"
        }
        else if(class_id === 228) {

            console.log("kkks")
            partNumber = "NIS5820 eFuse"

        }
        else if(class_id === 229) {
            partNumber = "NIS5232 eFuse"
        }
        else {
            console.log("platform undefined")
        }
    }

}
