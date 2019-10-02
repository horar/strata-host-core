import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id: root
    width: 200
    height:200
    color:"dimgray"
    opacity:1
    radius: 10

    property alias speakerTemperature: speakerTemperature.value
    property alias speakerResistance: speakerResistance.value
    property alias resonantFrequency: resonantFrequency.value
    property alias qesValue: qes.value
    property alias qmsValue: qms.value
    property alias qtsValue: qts.value
    property alias rmsValue: rms.value
    property alias cmsValue: cms.value

    property int statBoxHeight: 60

    PortStatBox{
        id:speakerTemperature

        height:statBoxHeight
        anchors.top: parent.top
        anchors.topMargin: 10
        label: "AMPLIFIER TEMPERATURE"
        unit:"°F"
        color:"transparent"
        icon: "../images/icon-temp.svg"
        valueSize: 32
        textColor: "white"
        portColor: "#2eb457"
        labelColor:"white"
        //underlineWidth: 40
        imageHeightPercentage: .65
        bottomMargin: 10
    }

    PortStatBox{
        id:speakerResistance

        height:statBoxHeight
        anchors.top: speakerTemperature.bottom
        label: "SPEAKER RESISTANCE"
        unit:"\u2126"
        color:"transparent"
        valueSize: 32
        textColor: "white"
        portColor: "#2eb457"
        labelColor:"white"
        //underlineWidth: 0
        imageHeightPercentage: .65
        bottomMargin: 10
    }

    PortStatBox{
        id:resonantFrequency

        height:statBoxHeight
        anchors.top: speakerResistance.bottom
        label: "RESONANT FREQUENCY"
        unit:"Hz"
        color:"transparent"
        valueSize: 32
        textColor: "white"
        portColor: "#2eb457"
        labelColor:"white"
        //underlineWidth: 0
        imageHeightPercentage: .65
        bottomMargin: 10
    }

    PortStatBox{
        id:qes

        height:statBoxHeight
        anchors.top: resonantFrequency.bottom
        label: "QES"
        underlineWidth: 100
        unit:""
        color:"transparent"
        valueSize: 32
        textColor: "white"
        portColor: "#2eb457"
        labelColor:"white"
        //underlineWidth: 0
        imageHeightPercentage: .65
        bottomMargin: 10
    }

    PortStatBox{
        id:qms

        height:statBoxHeight
        anchors.top: qes.bottom
        label: "QMS"
        underlineWidth: 100
        unit:""
        color:"transparent"
        valueSize: 32
        textColor: "white"
        portColor: "#2eb457"
        labelColor:"white"
        //underlineWidth: 0
        imageHeightPercentage: .65
        bottomMargin: 10
    }

    PortStatBox{
        id:qts

        height:statBoxHeight
        anchors.top: qms.bottom
        label: "QTS"
        underlineWidth: 100
        unit:""
        color:"transparent"
        valueSize: 32
        textColor: "white"
        portColor: "#2eb457"
        labelColor:"white"
        //underlineWidth: 0
        imageHeightPercentage: .65
        bottomMargin: 10
    }
    PortStatBox{
        id:rms

        height:statBoxHeight
        anchors.top: qts.bottom
        label: "RMS"
        underlineWidth: 100
        unit:""
        color:"transparent"
        valueSize: 32
        textColor: "white"
        portColor: "#2eb457"
        labelColor:"white"
        //underlineWidth: 0
        imageHeightPercentage: .65
        bottomMargin: 10
    }
    PortStatBox{
        id:cms

        height:statBoxHeight
        anchors.top: rms.bottom
        label: "CMS"
        underlineWidth: 100
        unit:""
        color:"transparent"
        valueSize: 32
        textColor: "white"
        portColor: "#2eb457"
        labelColor:"white"
        //underlineWidth: 0
        imageHeightPercentage: .65
        bottomMargin: 10
    }

}