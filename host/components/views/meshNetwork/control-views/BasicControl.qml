import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0
import "BasicViews"

Rectangle {
    id: root
    visible: true
    //anchors.fill:parent



   SGComboBox{
       id:basicViewCombo
       anchors.top:parent.top
       anchors.topMargin: 20
       anchors.left:parent.left
       anchors.leftMargin: 20
       width: 200
       model: [ "Office", "Smart home"]

       onCurrentIndexChanged: {
           if (currentIndex === 0){
                //configure the view for the office
               basicControlContainer.currentIndex = 0
           }
           else if (currentIndex === 1){
               //configure the view for the smart home
              basicControlContainer.currentIndex = 1
            }

       }
   }

   StackLayout {
       id: basicControlContainer
       anchors {
           top: basicViewCombo.bottom
           bottom: parent.bottom
           right: parent.right
           left: parent.left
       }

       Office {
           id: officeView
       }

       SmartHome {
           id: smartHomeView
       }
   }


}
