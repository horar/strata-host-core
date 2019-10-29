import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
//import tech.strata.sgwidgets 0.9
import QtQuick.Controls 2.4

Rectangle {
    id: root
    //width: parent.width
    //height:parent.height
    color:"dimgray"
    opacity:1
    radius: 10

    property int bandWidth: root.width/12
    property int bandHeight: root.height - (eqText.height + 10)

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
        color:"white"
        font.pixelSize: 36
        anchors.top:parent.top
        anchors.topMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
    }

  Row{
      id:bands
      anchors.top:eqText.bottom
      anchors.left:root.left
      anchors.leftMargin: 20
      anchors.right:root.right
      anchors.bottom:root.bottom
      spacing: 10

      EqualizerBand{
          id:band1
          width:bandWidth
          height: bandHeight
          name:"125Hz"

          sliderValue: platformInterface.equalizer_levels.band1

          onEqValueChanged:{
              platformInterface.set_equalizer_levels.update(band1.sliderLevel, band2.sliderLevel,band3.sliderLevel,
                                                     band4.sliderLevel,band5.sliderLevel,band6.sliderLevel,
                                                     band7.sliderLevel, band8.sliderLevel, band9.sliderLevel, band10.sliderLevel);
          }
      }
      EqualizerBand{
          id:band2
          width:bandWidth
          height: bandHeight
          name:"250 Hz"
          sliderValue: platformInterface.equalizer_levels.band2
          onEqValueChanged:{
              platformInterface.set_equalizer_levels.update(band1.sliderLevel, band2.sliderLevel,band3.sliderLevel,
                                                     band4.sliderLevel,band5.sliderLevel,band6.sliderLevel,
                                                     band7.sliderLevel, band8.sliderLevel, band9.sliderLevel, band10.sliderLevel);
          }
      }
      EqualizerBand{
          id:band3
          width:bandWidth
          height: bandHeight
          name:"500 Hz"
          sliderValue: platformInterface.equalizer_levels.band3
          onEqValueChanged:{
              platformInterface.set_equalizer_levels.update(band1.sliderLevel, band2.sliderLevel,band3.sliderLevel,
                                                     band4.sliderLevel,band5.sliderLevel,band6.sliderLevel,
                                                     band7.sliderLevel, band8.sliderLevel, band9.sliderLevel, band10.sliderLevel);
          }

      }
      EqualizerBand{
          id:band4
          width:bandWidth
          height: bandHeight
          name:"1 kHz"
          sliderValue: platformInterface.equalizer_levels.band4
          onEqValueChanged:{
              platformInterface.set_equalizer_levels.update(band1.sliderLevel, band2.sliderLevel,band3.sliderLevel,
                                                     band4.sliderLevel,band5.sliderLevel,band6.sliderLevel,
                                                     band7.sliderLevel, band8.sliderLevel, band9.sliderLevel, band10.sliderLevel);
          }

      }
      EqualizerBand{
          id:band5
          width:bandWidth
          height: bandHeight
          name:"2 kHz"
          sliderValue: platformInterface.equalizer_levels.band5
          onEqValueChanged:{
              platformInterface.set_equalizer_levels.update(band1.sliderLevel, band2.sliderLevel,band3.sliderLevel,
                                                     band4.sliderLevel,band5.sliderLevel,band6.sliderLevel,
                                                     band7.sliderLevel, band8.sliderLevel, band9.sliderLevel, band10.sliderLevel);
          }

      }
      EqualizerBand{
          id:band6
          width:bandWidth
          height: bandHeight
          name:"4 kHz"
          sliderValue: platformInterface.equalizer_levels.band6
          onEqValueChanged:{
              platformInterface.set_equalizer_levels.update(band1.sliderLevel, band2.sliderLevel,band3.sliderLevel,
                                                     band4.sliderLevel,band5.sliderLevel,band6.sliderLevel,
                                                     band7.sliderLevel, band8.sliderLevel, band9.sliderLevel, band10.sliderLevel);
          }

      }
      EqualizerBand{
          id:band7
          width:bandWidth
          height: bandHeight
          name:"6 kHz"
          sliderValue: platformInterface.equalizer_levels.band7
          onEqValueChanged:{
              platformInterface.set_equalizer_levels.update(band1.sliderLevel, band2.sliderLevel,band3.sliderLevel,
                                                     band4.sliderLevel,band5.sliderLevel,band6.sliderLevel,
                                                     band7.sliderLevel, band8.sliderLevel, band9.sliderLevel, band10.sliderLevel);
          }

      }
      EqualizerBand{
          id:band8
          width:bandWidth
          height: bandHeight
          name:"8 kHz"
          sliderValue: platformInterface.equalizer_levels.band8
          onEqValueChanged:{
              platformInterface.set_equalizer_levels.update(band1.sliderLevel, band2.sliderLevel,band3.sliderLevel,
                                                     band4.sliderLevel,band5.sliderLevel,band6.sliderLevel,
                                                     band7.sliderLevel, band8.sliderLevel, band9.sliderLevel, band10.sliderLevel);
          }

      }
      EqualizerBand{
          id:band9
          width:bandWidth
          height: bandHeight
          name:"12 kHz"
          sliderValue: platformInterface.equalizer_levels.band9
          onEqValueChanged:{
              platformInterface.set_equalizer_levels.update(band1.sliderLevel, band2.sliderLevel,band3.sliderLevel,
                                                     band4.sliderLevel,band5.sliderLevel,band6.sliderLevel,
                                                     band7.sliderLevel, band8.sliderLevel, band9.sliderLevel, band10.sliderLevel);
          }

      }
      EqualizerBand{
          id:band10
          width:bandWidth
          height: bandHeight
          name:"16 kHz"
          sliderValue: platformInterface.equalizer_levels.band10
          onEqValueChanged:{
              platformInterface.set_equalizer_levels.update(band1.sliderLevel, band2.sliderLevel,band3.sliderLevel,
                                                     band4.sliderLevel,band5.sliderLevel,band6.sliderLevel,
                                                     band7.sliderLevel, band8.sliderLevel, band9.sliderLevel, band10.sliderLevel);
          }

      }

  }
}


