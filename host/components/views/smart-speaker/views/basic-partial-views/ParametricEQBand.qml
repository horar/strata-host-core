import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
//import tech.strata.sgwidgets 0.9
import QtQuick.Controls 2.4

Rectangle {
    id: root
    color:"transparent"

    property alias name: bandLabel.text
    property alias sliderValue: bandSlider.value

    signal eqValueChanged()

    Slider{
        id:bandSlider
        anchors.top:parent.top
        //height:350
        //width:50
        anchors.bottom:bandText.top
        orientation: Qt.Vertical

        from:-18
        to:18
        value: root.sliderValue

        onMoved:{
            //send info to the platformInterface
            bandText.text = value.toFixed(0)
            root.eqValueChanged();
        }
    }
    TextField{
        id:bandText

        anchors.left:parent.left
        anchors.right:parent.horizontalCenter
        anchors.bottom:bandLabel.top
        anchors.bottomMargin: 20
        height:25

        text: bandSlider.value
    }
    Label{
        id:bandUnitsText
        anchors.left: bandText.right
        anchors.right:parent.right
        anchors.leftMargin: 5
        anchors.verticalCenter: bandText.verticalCenter
        color:"white"
        text:"dB"
    }
    Label{
        id:bandLabel
        //anchors.horizontalCenter: band1.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        text:"Band 1"
        color:"white"
    }
}






