import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
//import tech.strata.sgwidgets 0.9
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.0

Rectangle {
    id: root
    //width: parent.width
    //height:parent.height
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"
    property int bandWidth: root.width/12
    property int bandHeight: root.height -50 - (eqText.height + 10)
    property var eqValues:{'band1': band1.sliderValue,
                           'band2':  band2.sliderValue,
                            'band3':  band3.sliderValue,
                            'band4':  band4.sliderValue,
                            'band5':  band5.sliderValue,
                            'band6':  band6.sliderValue,
                            'band7':  band7.sliderValue,
                            'band8':  band8.sliderValue,
                            'band9':  band9.sliderValue,
                            'band10':  band10.sliderValue}

    onBandWidthChanged: {
        console.log("band width is",bandWidth)
    }

//    Rectangle{
//        anchors.top:eqText.bottom
//        anchors.left:root.left
//        anchors.leftMargin: 20
//        anchors.right:root.right
//        anchors.bottom:root.bottom
//        color:"transparent"
//        border.color:"red"
//    }

    Text{
        id:eqText
        text:"Equalizer"
        color:"black"
        font.pixelSize: 36
        anchors.top:parent.top
        anchors.topMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
    }

  Row{
      id:bands
      anchors.top:eqText.bottom
      anchors.topMargin:10
      anchors.left:root.left
      anchors.leftMargin: 20
      anchors.right:root.right
      //anchors.bottom:buttonRow.top
      spacing: 10

      EqualizerBand{
          id:band1
          width:bandWidth
          height: bandHeight
          name:"32Hz"

          property var eqLevel: platformInterface.equalizer_level
          onEqLevelChanged: {
              if (platformInterface.equalizer_level.band === 1)
                  sliderValue = platformInterface.equalizer_level.level
          }

          onEqValueChanged:{
              platformInterface.set_equalizer_level.update(1, band1.sliderValue);
          }
      }
      EqualizerBand{
          id:band2
          width:bandWidth
          height: bandHeight
          name:"64 Hz"

          property var eqLevel: platformInterface.equalizer_level
          onEqLevelChanged: {
              if (platformInterface.equalizer_level.band === 2)
                  sliderValue = platformInterface.equalizer_level.level
          }

          onEqValueChanged:{
              platformInterface.set_equalizer_level.update(2,band2.sliderValue);
          }
      }
      EqualizerBand{
          id:band3
          width:bandWidth
          height: bandHeight
          name:"125 Hz"

          property var eqLevel: platformInterface.equalizer_level
          onEqLevelChanged: {
              if (platformInterface.equalizer_level.band === 3)
                  sliderValue = platformInterface.equalizer_level.level
          }

          onEqValueChanged:{
              platformInterface.set_equalizer_level.update(3,band3.sliderValue);
          }

      }
      EqualizerBand{
          id:band4
          width:bandWidth
          height: bandHeight
          name:"250 Hz"

          property var eqLevel: platformInterface.equalizer_level
          onEqLevelChanged: {
              if (platformInterface.equalizer_level.band === 4)
                  sliderValue = platformInterface.equalizer_level.level
          }

          onEqValueChanged:{
              platformInterface.set_equalizer_level.update(4,band4.sliderValue);
          }

      }
      EqualizerBand{
          id:band5
          width:bandWidth
          height: bandHeight
          name:"500 Hz"

          property var eqLevel: platformInterface.equalizer_level
          onEqLevelChanged: {
              if (platformInterface.equalizer_level.band === 5)
                  sliderValue = platformInterface.equalizer_level.level
          }

          onEqValueChanged:{
              platformInterface.set_equalizer_level.update(5, band5.sliderValue);
          }

      }
      EqualizerBand{
          id:band6
          width:bandWidth
          height: bandHeight
          name:"1 kHz"

          property var eqLevel: platformInterface.equalizer_level
          onEqLevelChanged: {
              if (platformInterface.equalizer_level.band === 6)
                  sliderValue = platformInterface.equalizer_level.level
          }

          onEqValueChanged:{
              platformInterface.set_equalizer_level.update(6,band6.sliderValue);
          }

      }
      EqualizerBand{
          id:band7
          width:bandWidth
          height: bandHeight
          name:"2 kHz"

          property var eqLevel: platformInterface.equalizer_level
          onEqLevelChanged: {
              if (platformInterface.equalizer_level.band === 7)
                  sliderValue = platformInterface.equalizer_level.level
          }

          onEqValueChanged:{
              platformInterface.set_equalizer_level.update(7, band1.sliderValue);
          }

      }
      EqualizerBand{
          id:band8
          width:bandWidth
          height: bandHeight
          name:"4 kHz"

          property var eqLevel: platformInterface.equalizer_level
          onEqLevelChanged: {
              if (platformInterface.equalizer_level.band === 8)
                  sliderValue = platformInterface.equalizer_level.level
          }

          onEqValueChanged:{
              platformInterface.set_equalizer_level.update(8, band8.sliderValue);
          }

      }
      EqualizerBand{
          id:band9
          width:bandWidth
          height: bandHeight
          name:"8 kHz"

          property var eqLevel: platformInterface.equalizer_level
          onEqLevelChanged: {
              if (platformInterface.equalizer_level.band === 9)
                  sliderValue = platformInterface.equalizer_level.level
          }

          onEqValueChanged:{
              platformInterface.set_equalizer_level.update(9, band9.sliderValue);
          }

      }
      EqualizerBand{
          id:band10
          width:bandWidth
          height: bandHeight
          name:"16 kHz"

          property var eqLevel: platformInterface.equalizer_level
          onEqLevelChanged: {
              if (platformInterface.equalizer_level.band === 10)
                  sliderValue = platformInterface.equalizer_level.level
          }

          onEqValueChanged:{
              platformInterface.set_equalizer_level.update(10, band10.sliderValue);
          }

      }

  }
  Row{
      id:buttonRow
      anchors.top:bands.bottom
      anchors.left:root.left
      anchors.leftMargin: 0
      anchors.right:root.right
      anchors.bottom:root.bottom
      spacing: 10

      Rectangle{
          id:spacerRectangle
          width: (root.width - (saveEQButton.width + loadEQButton.width +buttonRow.spacing))/2
          height:20
          color:"transparent"
      }

      Button{
          id:saveEQButton
          width:75
          height:30
          text:"save"


          contentItem: Text {
              text: saveEQButton.text
              font.pixelSize: 18
              opacity: enabled ? 1.0 : 0.3
              color: "black"
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              elide: Text.ElideRight
          }

          background: Rectangle {
              opacity: .8
              border.color: "black"
              color: saveEQButton.checked ? "dimgrey": "white"
              border.width: 1
              radius: width/2
          }

          property real unmuttedMasterVolume;

          onClicked:{
              //save off the EQ to disk
              saveFileDialog.open()
          }
      }

      Button{
          id:loadEQButton
          width:75
          height:30
          text:"load"


          contentItem: Text {
              text: loadEQButton.text
              font.pixelSize: 18
              opacity: enabled ? 1.0 : 0.3
              color: "black"
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              elide: Text.ElideRight
          }

          background: Rectangle {
              opacity: .8
              border.color: "black"
              color: loadEQButton.checked ? "dimgrey": "white"
              border.width: 1
              radius: width/2
          }

          property real unmuttedMasterVolume;

          onClicked:{
              //load EQ from disk
              openFileDialog.open()
          }
      }
  }

  function openFile(fileUrl) {
          var request = new XMLHttpRequest();
          request.open("GET", fileUrl, false);
          request.send(null);
          return request.responseText;
      }

      function saveFile(fileUrl, text) {
          var request = new XMLHttpRequest();
          request.open("PUT", fileUrl, false);
          request.send(text);
          return request.status;
      }

  FileDialog {
          id: openFileDialog
          title:"Load EQ setting"
          selectMultiple: false
          folder:shortcuts.documents
          nameFilters: ["Text files (*.txt)", "All files (*)"]
          onAccepted: {
              //get the JSON string back from disk
              var theString = openFile(openFileDialog.fileUrl)
              //console.log("string is",theString)
              //then parse the JSON and put the values back in the array
              //before updating the controls.
              root.eqValues = JSON.parse(theString)

              band1.sliderValue = root.eqValues.band1;
              band2.sliderValue = root.eqValues.band2;
              band3.sliderValue = root.eqValues.band3;
              band4.sliderValue = root.eqValues.band4;
              band5.sliderValue = root.eqValues.band5;
              band6.sliderValue = root.eqValues.band6;
              band7.sliderValue = root.eqValues.band7;
              band8.sliderValue = root.eqValues.band8;
              band9.sliderValue = root.eqValues.band9;
              band10.sliderValue = root.eqValues.band10;
          }
      }

  FileDialog {
          id: saveFileDialog
          title:"Save EQ setting"
          selectExisting: false
          folder:shortcuts.documents
          nameFilters: ["Text files (*.txt)", "All files (*)"]
          //turn the eq values into a JSON string in order to save them to disk
          onAccepted: saveFile(saveFileDialog.fileUrl, JSON.stringify(root.eqValues))
      }
}


