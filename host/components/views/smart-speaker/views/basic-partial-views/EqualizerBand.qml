import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.4
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root
    color:"transparent"

    property alias name: bandLabel.text
    property alias sliderValue: bandSlider.value
    property color grooveColor: "#353637"
    property color grooveFillColor: "#E4E4E4"
    property color accentColor: "#86724C"


    signal eqValueChanged()

    SGSlider{
        id:bandSlider
        anchors.top:parent.top
        //height:350
        //width:50
        anchors.bottom:bandText.top
        anchors.bottomMargin: 5
        orientation: Qt.Vertical
        live:false  //done to help throddle the number of messages sent
        showInputBox: false
        showLabels: false
        showToolTip: false
        grooveColor: root.grooveColor
        fillColor: hightlightColor
        handleSize: 30
        stepSize: 1
        from:-18
        to:18


        onPressedChanged: {
            if (!pressed){
                let fixedValue = value.toFixed(0)
                if (fixedValue === "-0")
                    fixedValue = "0"
                 bandText.text = fixedValue
                 root.eqValueChanged();
            }
        }

//        onMoved:{
//            //send info to the platformInterface
//            bandText.text = value.toFixed(0)
//            root.eqValueChanged();
//        }
    }
    TextField{
        id:bandText

        anchors.horizontalCenter: bandSlider.horizontalCenter
        anchors.bottom:bandLabel.top
        anchors.bottomMargin: 20
        height:25
        width:35

        text: bandSlider.value.toFixed(0)

        onActiveFocusChanged: {
                // When we first gain focus, save the old text and select everything for clearing.
                if (activeFocus) {
                    selectAll()
                }
            }

        onEditingFinished: {
            bandSlider.value = text;
            root.eqValueChanged();
        }
    }
//    Label{
//        id:bandUnitsText
//        anchors.left: bandText.right
//        anchors.right:parent.right
//        anchors.leftMargin: 5
//        anchors.verticalCenter: bandText.verticalCenter
//        color:"white"
//        text:"dB"
//    }
    Label{
        id:bandLabel
        //anchors.horizontalCenter: band1.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        text:"Band 1"
        color:accentColor
    }
}






