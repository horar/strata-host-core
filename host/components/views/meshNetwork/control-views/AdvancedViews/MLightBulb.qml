import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0

Image{
    id:lightBulbOff
    source: "../../images/lightBulbOff.svg"
    height:parent.height * .25
    fillMode: Image.PreserveAspectFit
    mipmap:true

    property alias onOpacity: lightBulbOn.opacity
    signal bulbClicked

    Image{
        id:lightBulbOn
        anchors.fill:lightBulbOff
        source: "../../images/lightBulbOn.svg"
        height:parent.height * .25
        fillMode: Image.PreserveAspectFit
        mipmap:true
        opacity:0

        Behavior on opacity {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutCubic
            }
        }

        MouseArea{
            id:bulbClickArea
            anchors.fill:parent

            onClicked:{
                lightBulbOff.bulbClicked()
            }


        }
    }
}
