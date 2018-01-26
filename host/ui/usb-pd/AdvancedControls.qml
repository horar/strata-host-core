import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import tech.spyglass.ImplementationInterfaceBinding 1.0
import "framework"

Rectangle {

    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 8;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 16;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;


    objectName: "advancedControls"


//    ListModel {
//        id: faultHistoryList
//    }

//    ListModel {
//        id: activeFaultList
//    }
//    // signal handling
//    Connections {
//        target: implementationInterfaceBinding

//        onMinimumVoltageChanged: {
//            faultHistoryList.append()

//        }
//    }

    GridLayout {
        id: grid
        columns: 3
        rows: 3
        anchors {fill:parent}
        columnSpacing: 0
        rowSpacing: 0

        property double colMulti : grid.width / grid.columns
        property double rowMulti : grid.height / grid.rows

        function prefWidth(item){
            return colMulti * item.Layout.columnSpan
        }
        function prefHeight(item){
            return rowMulti * item.Layout.rowSpan
        }       

        Rectangle {
            id:settings

            property var collapseAnimationSpeed:900

            //columns 0 and 1, both rows
            Layout.column: 0
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 3
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true

            color: "black"

            ColumnLayout{
                id:settingsColumn
                spacing: 0

                //for this to work, does the column need to be inside a flickable?
//                ScrollBar.vertical: ScrollBar{
//                    parent: settingsColumn.parent
//                    anchors.top: settingsColumn.top
//                    anchors.left: settingsColumn.right
//                    anchors.bottom: settingsColumn.bottom
//                }

                Rectangle{
                    id: boardSettings
                    Layout.preferredWidth  : grid.prefWidth(this)
                    Layout.preferredHeight : grid.prefHeight(this)
                    color: "black"

                    NumberAnimation{
                        id: collapseBoardSettings
                        target: boardSettings;
                        property: "Layout.preferredHeight";
                        to: 60;
                        duration: settings.collapseAnimationSpeed;
                    }

                    NumberAnimation {
                        id: expandBoardSettings
                        target: boardSettings
                        property: "Layout.preferredHeight";
                        to: grid.prefHeight(boardSettings);
                        duration: settings.collapseAnimationSpeed;
                    }

                    Button{
                        id: boardSettingsDisclosureButton
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.topMargin: 20
                        height: 20//parent.width/20
                        width: 20//parent.width/40
                        checkable: true
                        checked: true
                        background: Rectangle {
                            //color: boardSettingsDisclosureButton.checked ? "green" : "red"
                            color:"black"
                        }


                        Image{
                            id:boardSettingsDisclosureButtonImage
                            anchors.left:parent.left
                            anchors.leftMargin: 3
                            anchors.top:parent.top
                            height:10
                            width:14
                            source:"./images/icons/showLessIcon.svg"

                            transform: Rotation {
                                id: rotateBoardSettingsButtonImage
                                origin.x: boardSettingsDisclosureButtonImage.width/2;
                                origin.y: boardSettingsDisclosureButtonImage.height/2;
                                axis { x: 0; y: 0; z: 1 }
                            }

                            NumberAnimation {
                                id:collapseBoardSettingsDisclosureIcon
                                running: false
                                loops: 1
                                target: rotateBoardSettingsButtonImage;
                                property: "angle";
                                from: 0; to: 180;
                                duration: 1000;
                            }

                            NumberAnimation {
                                id:expandBoardSettingsDisclosureIcon
                                running: false
                                loops: 1
                                target: rotateBoardSettingsButtonImage;
                                property: "angle";
                                from: 180; to: 0;
                                duration: 1000;
                            }
                        }


                        onClicked:{
                            if (checked == true){
                                expandBoardSettings.start();
                                expandBoardSettingsDisclosureIcon.start()
                                }
                            else{
                                collapseBoardSettings.start();
                                collapseBoardSettingsDisclosureIcon.start()
                              }
                        }

                    }

                    Label{
                        id: boardSettingsLabel
                        text: "Board Settings"
                        font.family: "Helvetica"
                        font.pointSize: mediumFontSize
                        color: "#D8D8D8"
                        anchors.left:parent.left
                        anchors.top:parent.top
                        anchors.leftMargin: 20
                        anchors.topMargin: 20
                    }

                    Rectangle{
                        id: boardSettingsSeparator
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: parent.width/20
                        anchors.rightMargin: parent.width/20
                        anchors.top: boardSettingsLabel.bottom
                        anchors.topMargin: boardSettingsLabel.height
                        height: 1
                        color:"#CCCCCC"
                    }

                    Rectangle{
                        id:inputLimitingGroup
                        color:"#33FFFFFF"
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        anchors.top: boardSettingsSeparator.bottom
                        anchors.topMargin: boardSettingsLabel.height
                        height: 100

                        Text{
                            id:inputLimitingText
                            text:"Input Limiting"
                            font.family: "helvetica"
                            font.pointSize: mediumFontSize
                            color: "#D8D8D8"
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.top: parent.top
                            anchors.topMargin: 5
                        }

                        Switch{
                            id: inputLimitingSwitch
                            anchors.left: inputLimitingText.right
                            anchors.leftMargin: 10
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            height: 15
                            width:30
                            checked:true
                            //this is the background of the switch
                            indicator: Rectangle {
                                implicitWidth: 30
                                implicitHeight: 15
                                x: inputLimitingSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 7
                                color: inputLimitingSwitch.checked ? "#0078D7"  : "black"
                                border.color: inputLimitingSwitch.checked ? "#0078D7" : "white"

                                  //this is the thumb that moves
                                Rectangle {
                                    x: inputLimitingSwitch.checked ? parent.width - width : 0
                                    y: parent.height / 2 - height / 2
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: "white"
                                }
                            }
                            onToggled: {
                                //toggle enablement of the input limiting controls
                                startLimitingText.enabled = inputLimitingSwitch.checked
                                startLimitingVoltageTextInput.enabled = inputLimitingSwitch.checked
                                startLimitingUnitText.enabled = inputLimitingSwitch.checked
                                startLimitingVoltageTextInput.enabled = inputLimitingSwitch.checked
                                startLimitingUnitText.enabled = inputLimitingSwitch.checked
                                outputLimitText.enabled = inputLimitingSwitch.checked
                                outputLimitTextInput.enabled = inputLimitingSwitch.checked
                                outputLimitUnitText.enabled = inputLimitingSwitch.checked
                                minimumInputVoltageText.enabled = inputLimitingSwitch.checked
                                minimumInputTextInput.enabled = inputLimitingSwitch.checked
                                minimumInputUnitText.enabled = inputLimitingSwitch.checked
                                minimumInputVoltageSlider.enabled = inputLimitingSwitch.checked
                            }
                        }

                        Text{
                            id:startLimitingText
                            text:"Start limiting at:"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            horizontalAlignment: Text.AlignRight
                            color: "#D8D8D8"
                            anchors.right:parent.right
                            anchors.rightMargin: parent.width*.6
                            anchors.top: inputLimitingText.bottom
                            anchors.topMargin: 10

                        }
                        TextField{
                            id:startLimitingVoltageTextInput
                            anchors.left:startLimitingText.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: startLimitingText.verticalCenter
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:30
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                            onEditingFinished: {
                                //keep the values in the correct range
                                if (startLimitingVoltageTextInput.text >32){
                                    startLimitingVoltageTextInput.text = 32
                                }
                                else if (startLimitingVoltageTextInput.text <5){
                                    startLimitingVoltageTextInput.text = 5
                                }
                                implementationInterfaceBinding.setInputVoltageLimiting(parseInt(startLimitingVoltageTextInput.text))
                                console.log ("user set value for start limiting:", startLimitingVoltageTextInput.text)
                            }
                        }
                        Text{
                            id:startLimitingUnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            //horizontalAlignment: Text.AlignRight
                            color: "#D8D8D8"
                            anchors.left:startLimitingVoltageTextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: startLimitingText.verticalCenter

                        }

                        Text{
                            id:outputLimitText
                            text:"Limit Board Output to:"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            horizontalAlignment: Text.AlignRight
                            color: "#D8D8D8"
                            anchors.right:parent.right
                            anchors.rightMargin: parent.width*.6
                            anchors.top: startLimitingText.bottom
                            anchors.topMargin: 10
                        }
                        TextField{
                            id:outputLimitTextInput
                            anchors.left:outputLimitText.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: outputLimitText.verticalCenter
                            color:"white"//"#838484"
                            placeholderText:"7"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:30
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                            onEditingFinished: {
                                //keep the values in the correct range
                                if (outputLimitTextInput.text >32){
                                    outputLimitTextInput.text = 32
                                }
                                else if (outputLimitTextInput.text <5){
                                    outputLimitTextInput.text = 5
                                }

                                console.log ("user set value for output limiting:", outputLimitTextInput.text)
                            }
                        }
                        Text{
                            id:outputLimitUnitText
                            text:"W"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            //horizontalAlignment: Text.AlignRight
                            color: "#D8D8D8"
                            anchors.left:outputLimitTextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: outputLimitText.verticalCenter

                        }

                        Text{
                            id:minimumInputVoltageText
                            text:"Minimum input voltage:"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            horizontalAlignment: Text.AlignRight
                            color: "#D8D8D8"
                            anchors.right:parent.right
                            anchors.rightMargin: parent.width*.6
                            anchors.top: outputLimitText.bottom
                            anchors.topMargin: 10
                        }
                        Label{
                            id:minimumInputTextInput
                            anchors.left:minimumInputVoltageText.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: minimumInputVoltageText.verticalCenter
                            anchors.verticalCenterOffset: 2
                            color:"white"
                            text:minimumInputVoltageSlider.value
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                        }
                        Text{
                            id:minimumInputUnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:minimumInputTextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: minimumInputVoltageText.verticalCenter

                        }
                        Slider{
                            id:minimumInputVoltageSlider
                            anchors.left:minimumInputUnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: minimumInputVoltageText.verticalCenter
                            height:10
                            from: 5
                            to:32
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: minimumInputVoltageSlider.leftPadding
                                    y: minimumInputVoltageSlider.topPadding + minimumInputVoltageSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: minimumInputVoltageSlider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: minimumInputVoltageSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: minimumInputVoltageSlider.leftPadding + minimumInputVoltageSlider.visualPosition * (minimumInputVoltageSlider.availableWidth - width)
                                    y: minimumInputVoltageSlider.topPadding + minimumInputVoltageSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }

                                onMoved: {
                                    minimumInputTextInput.text = Math.round(minimumInputVoltageSlider.value *10)/10

                                }


                        }

                    }

                    //------------------------------------
                    //  temperature limit Group
                    //---------------------------------
                    Rectangle{
                        id:temperatureLimitingGroup
                        color:"#33FFFFFF"
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        anchors.top: inputLimitingGroup.bottom
                        anchors.topMargin: boardSettingsLabel.height
                        height: 100

                        Text{
                            id:temperatureLimitingText
                            text:"Temperature Limiting"
                            font.family: "helvetica"
                            font.pointSize: mediumFontSize
                            color: "#D8D8D8"
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.top: parent.top
                            anchors.topMargin: 5
                        }

                        Switch{
                            id: temperatureLimitingSwitch
                            anchors.left: temperatureLimitingText.right
                            anchors.leftMargin: 10
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            height: 15
                            width:30
                            checked:true
                            //this is the background of the switch
                            indicator: Rectangle {
                                implicitWidth: 30
                                implicitHeight: 15
                                x: temperatureLimitingSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 7
                                color: temperatureLimitingSwitch.checked ? "#0078D7"  : "black"
                                border.color: temperatureLimitingSwitch.checked ? "#0078D7" : "white"

                                  //this is the thumb that moves
                                Rectangle {
                                    x: temperatureLimitingSwitch.checked ? parent.width - width : 0
                                    y: parent.height / 2 - height / 2
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: "white"
                                }
                            }
                            onToggled: {
                                //toggle enablement of the input limiting controls
                                boardTemperatureText.enabled = temperatureLimitingSwitch.checked
                                boardTemperatureTextInput.enabled = temperatureLimitingSwitch.checked
                                boardTemperatureUnitText.enabled = temperatureLimitingSwitch.checked
                                boardOutputLimitText.enabled = temperatureLimitingSwitch.checked
                                boardOutputTextInput.enabled = temperatureLimitingSwitch.checked
                                boardOutputUnitText.enabled = temperatureLimitingSwitch.checked
                                faultTempText.enabled = temperatureLimitingSwitch.checked
                                faultTempLabel.enabled = temperatureLimitingSwitch.checked
                                faultTempUnitText.enabled = temperatureLimitingSwitch.checked
                                faultTempSlider.enabled = temperatureLimitingSwitch.checked
                            }
                        }

                        Text{
                            id:boardTemperatureText
                            text:"When board temperature reaches:"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            horizontalAlignment: Text.AlignRight
                            color: "#D8D8D8"
                            anchors.right:parent.right
                            anchors.rightMargin: parent.width*.4
                            anchors.top: temperatureLimitingText.bottom
                            anchors.topMargin: 10

                        }
                        TextField{
                            id:boardTemperatureTextInput
                            anchors.left:boardTemperatureText.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: boardTemperatureText.verticalCenter
                            color:"white"//"#838484"
                            placeholderText:"70"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:30
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                            onEditingFinished: {
                                //keep the values in the correct range
                                if (boardTemperatureTextInput.text >32){
                                    boardTemperatureTextInput.text = 32
                                }
                                else if (boardTemperatureTextInput.text <5){
                                    boardTemperatureTextInput.text = 5
                                }
                                implementationInterfaceBinding.setMaximumTemperature(boardTemperatureTextInput.text)
                                console.log ("user set value for start limiting:", boardTemperatureTextInput.text)
                            }
                        }
                        Text{
                            id:boardTemperatureUnitText
                            text:"°C"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:boardTemperatureTextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: boardTemperatureText.verticalCenter

                        }

                        Text{
                            id:boardOutputLimitText
                            text:"Limit Board Output to:"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            horizontalAlignment: Text.AlignRight
                            color: "#D8D8D8"
                            anchors.right:parent.right
                            anchors.rightMargin: parent.width*.4
                            anchors.top: boardTemperatureText.bottom
                            anchors.topMargin: 10
                        }
                        TextField{
                            id:boardOutputTextInput
                            anchors.left:boardOutputLimitText.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: boardOutputLimitText.verticalCenter
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:30
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                            onEditingFinished: {
                                //keep the values in the correct range
                                if (boardOutputTextInput.text >32){
                                    boardOutputTextInput.text = 32
                                }
                                else if (boardOutputTextInput.text <5){
                                    boardOutputTextInput.text = 5
                                }
                                console.log ("user set value for start limiting:", boardOutputTextInput.text)
                            }
                        }

                        Text{
                            id:boardOutputUnitText
                            text:"W"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:boardOutputTextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: boardOutputLimitText.verticalCenter

                        }

                        Text{
                            id:faultTempText
                            text:"Fault when temperature reaches:"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            horizontalAlignment: Text.AlignRight
                            color: "#D8D8D8"
                            anchors.right:parent.right
                            anchors.rightMargin: parent.width*.4
                            anchors.top: boardOutputLimitText.bottom
                            anchors.topMargin: 10
                        }

                        Label{
                            id:faultTempLabel
                            anchors.left:faultTempText.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: faultTempText.verticalCenter
                            anchors.verticalCenterOffset: 2
                            color:"white"
                            text:minimumInputVoltageSlider.value
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                        }


                        Text{
                            id:faultTempUnitText
                            text:"°C"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:faultTempLabel.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: faultTempText.verticalCenter

                        }
                        Slider{
                            id:faultTempSlider
                            anchors.left:faultTempUnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: faultTempText.verticalCenter
                            height:10
                            from: 25
                            to:100
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: faultTempSlider.leftPadding
                                    y: faultTempSlider.topPadding + faultTempSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: faultTempSlider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: faultTempSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: faultTempSlider.leftPadding + faultTempSlider.visualPosition * (faultTempSlider.availableWidth - width)
                                    y: faultTempSlider.topPadding + faultTempSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }

                                onMoved: {
                                    faultTempLabel.text = Math.round(faultTempSlider.value *10)/10

                                }


                        }
                    }

                }

                //-----------------------------------------------
                //  Port 1 settings
                //-----------------------------------------------
                Rectangle{
                    id:port1Settings
                    Layout.preferredWidth  : grid.prefWidth(this)
                    Layout.preferredHeight : grid.prefHeight(this)
                    color: "black"

                    NumberAnimation{
                        id: collapsePort1Settings
                        target: port1Settings;
                        property: "Layout.preferredHeight";
                        to: 60;
                        duration: settings.collapseAnimationSpeed
                    }

                    NumberAnimation {
                        id: expandPort1Settings
                        target: port1Settings
                        property: "Layout.preferredHeight";
                        to: grid.prefHeight(port1Settings);
                        duration: settings.collapseAnimationSpeed;
                    }

                    Button{
                        id: port1SettingsDisclosureButton
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.topMargin: 20
                        height: 20//parent.width/20
                        width: 20//parent.width/40
                        checkable: true
                        checked: true
                        background: Rectangle {
                            color: "black"
                        }


                        Image{
                            id:port1DisclosureButtonImage
                            anchors.left:parent.left
                            anchors.leftMargin: 3
                            anchors.top:parent.top
                            height:10
                            width:14
                            source:"./images/icons/showLessIcon.svg"

                            transform: Rotation {
                                id: rotatePort1ButtonImage
                                origin.x: port1DisclosureButtonImage.width/2;
                                origin.y: port1DisclosureButtonImage.height/2;
                                axis { x: 0; y: 0; z: 1 }
                            }

                            NumberAnimation {
                                id:collapsePort1DisclosureIcon
                                running: false
                                loops: 1
                                target: rotatePort1ButtonImage;
                                property: "angle";
                                from: 0; to: 180;
                                duration: 1000;
                            }

                            NumberAnimation {
                                id:expandPort1DisclosureIcon
                                running: false
                                loops: 1
                                target: rotatePort1ButtonImage;
                                property: "angle";
                                from: 180; to: 0;
                                duration: 1000;
                            }
                        }

                        onClicked:{
                            if (checked == true){
                                expandPort1Settings.start();
                                expandPort1DisclosureIcon.start();
                                }
                            else{
                                collapsePort1Settings.start();
                                collapsePort1DisclosureIcon.start();
                              }
                        }

                    }

                    Label{
                        id: port1SettingsLabel
                        text: "Port 1 Settings"
                        font.family: "Helvetica"
                        font.pointSize: mediumFontSize
                        color: "#D8D8D8"
                        anchors.left:parent.left
                        anchors.top:parent.top
                        anchors.leftMargin: 20//parent.width/20
                        anchors.topMargin: 20//parent.height/20
                    }

                    Rectangle{
                        id: port1SettingsSeparator
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: parent.width/20
                        anchors.rightMargin: parent.width/20
                        anchors.top: port1SettingsLabel.bottom
                        anchors.topMargin: port1SettingsLabel.height
                        height: 1
                        color:"#CCCCCC"
                    }

                    Text{
                        id:port1CableCompensationText
                        text:"Cable compensation step:"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        horizontalAlignment: Text.AlignRight
                        color: "#D8D8D8"
                        anchors.right:parent.right
                        anchors.rightMargin: parent.width*.6
                        anchors.top: port1SettingsSeparator.bottom
                        anchors.topMargin: 10

                    }
                    TextField{
                        id:port1CableCompensationTextInput
                        anchors.left:port1CableCompensationText.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: port1CableCompensationText.verticalCenter
                        color:"white"//"#838484"
                        placeholderText:"70"
                        verticalAlignment: TextInput.AlignTop
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        height:15
                        width:30
                        background: Rectangle {
                                implicitWidth: 15
                                implicitHeight: 10
                                color: "#838484"//"#33FFFFFF"
                                border.color: "#838484"
                            }
                    }
                    Text{
                        id:port1CableCompensationUnitText
                        text:"A"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        color: "#D8D8D8"
                        anchors.left:port1CableCompensationTextInput.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: port1CableCompensationText.verticalCenter

                    }

                    Text{
                        id:voltageCompensationText
                        text:"Voltage compensation:"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        horizontalAlignment: Text.AlignRight
                        color: "#D8D8D8"
                        anchors.right:parent.right
                        anchors.rightMargin: parent.width*.6
                        anchors.top: port1CableCompensationText.bottom
                        anchors.topMargin: 10
                    }
                    TextField{
                        id:voltageCompensationTextInput
                        anchors.left:voltageCompensationText.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: voltageCompensationText.verticalCenter
                        color:"white"//"#838484"
                        placeholderText:"7"
                        verticalAlignment: TextInput.AlignTop
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        height:15
                        width:30
                        background: Rectangle {
                                implicitWidth: 15
                                implicitHeight: 10
                                color: "#838484"//"#33FFFFFF"
                                border.color: "#838484"
                            }
                    }
                    Text{
                        id:voltageCompensationUnitText
                        text:"mV"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        color: "#D8D8D8"
                        anchors.left:voltageCompensationTextInput.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: voltageCompensationText.verticalCenter

                    }

                    Text{
                        id:port1MaxPowerText
                        text:"Maximum power output:"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        horizontalAlignment: Text.AlignRight
                        color: "#D8D8D8"
                        anchors.right:parent.right
                        anchors.rightMargin: parent.width*.6
                        anchors.top: voltageCompensationText.bottom
                        anchors.topMargin: 10
                    }
                    ComboBox {
                        id:port1MaxPowerCombo
                         model: ["27", "36", "45","60","100"]
//                        textRole: "key"
//                        model: ListModel {
//                         id:model
//                                ListElement { key: "27"; value: 27 }
//                                ListElement { key: "36"; value: 36 }
//                                ListElement { key: "45"; value: 45 }
//                                ListElement { key: "60"; value: 60 }
//                                ListElement { key: "100"; value: 100 }
//                            }
                        anchors.left:port1MaxPowerText.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: port1MaxPowerText.verticalCenter
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        height:15
                        width:30

                        //this is used by the PopUp to determine what font to use
                        delegate: ItemDelegate {
                                width: port1MaxPowerCombo.width
                                height:15
                                contentItem: Text {
                                    text: modelData
                                    color: highlighted? "#D8D8D8" :"black"
                                    font: port2MaxPowerCombo.font
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked:{
                                    //here's where a click on a new selection should be handled
                                    implementationInterfaceBinding.setMaximumPortPower(1,modelData)
                                    console.log("clicked:", modelData)
                                }

                                highlighted: port1MaxPowerCombo.highlightedIndex === index
                            }

//                        indicator: Canvas {
//                                id: canvas
//                                x: port1MaxPowerCombo.width /*- width*/ - port1MaxPowerCombo.rightPadding
//                                y: port1MaxPowerCombo.topPadding + (port1MaxPowerCombo.availableHeight - height) / 2
//                                width: 12
//                                height: 8
//                                contextType: "2d"

//                                Connections {
//                                    target: port1MaxPowerCombo
//                                    onPressedChanged: canvas.requestPaint()
//                                }

//                                onPaint: {
//                                    context.reset();
//                                    context.moveTo(0, 0);
//                                    context.lineTo(width, 0);
//                                    context.lineTo(width / 2, height);
//                                    context.closePath();
//                                    context.fillStyle = "black";
//                                    context.fill();
//                                }
//                            }

                        background: Rectangle {
                                implicitWidth: 15
                                implicitHeight: 10
                                color: "#838484"
                                border.color: "#838484"
                            }

                        contentItem: Text {
                                leftPadding: 0
                                rightPadding: port1MaxPowerCombo.indicator.width + port1MaxPowerCombo.spacing

                                text: port1MaxPowerCombo.displayText
                                font: port1MaxPowerCombo.font
                                color: port1MaxPowerCombo.pressed ? "#17a81a" : "#D8D8D8"
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                        popup: Popup {
                            y: port1MaxPowerCombo.height - 1
                            width: port1MaxPowerCombo.width *2
                            implicitHeight: contentItem.implicitHeight
                            padding: 1
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            //color: "#D8D8D8"

                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: port1MaxPowerCombo.popup.visible ? port1MaxPowerCombo.delegateModel : null
                                currentIndex: port1MaxPowerCombo.highlightedIndex

                                ScrollIndicator.vertical: ScrollIndicator { }
                            }

                            background: Rectangle {
                                color: "#838484"
                                border.color: "#838484"
                            }
                        }
                    }
                    Text{
                        id:port1MaxPowerUnitText
                        text:"W"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        color: "#D8D8D8"
                        anchors.left:port1MaxPowerCombo.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: port1MaxPowerText.verticalCenter

                    }

                    Text{
                        id:maxCurrentText
                        text:"Maximum current:"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        horizontalAlignment: Text.AlignRight
                        color: "#D8D8D8"
                        anchors.right:parent.right
                        anchors.rightMargin: parent.width*.6
                        anchors.top: port1MaxPowerText.bottom
                        anchors.topMargin: 10
                    }
                    TextField{
                        id:maxCurrentTextInput
                        anchors.left:maxCurrentText.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: maxCurrentText.verticalCenter
                        color:"white"//"#838484"
                        placeholderText:"7"
                        verticalAlignment: TextInput.AlignTop
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        height:15
                        width:30
                        background: Rectangle {
                                implicitWidth: 15
                                implicitHeight: 10
                                color: "#838484"//"#33FFFFFF"
                                border.color: "#838484"
                            }
                    }
                    Text{
                        id:maxCurrentUnitText
                        text:"A"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        color: "#D8D8D8"
                        anchors.left:maxCurrentTextInput.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: maxCurrentText.verticalCenter

                    }

                    //-----------------------------------------------
                    //  advertized voltages group
                    //-----------------------------------------------
                    Rectangle{
                        id:port1AdvertizedVoltagesGroup
                        color:"black"//"#33FFFFFF"
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        anchors.top: maxCurrentText.bottom
                        anchors.topMargin: 10
                        height: 150
                        Text{
                            id:port1AdvertizedVoltagesLabel
                            text:"Advertized Voltages:"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.right:parent.right
                            anchors.rightMargin: parent.width*.6
                            anchors.top: parent.top
                            anchors.topMargin: 0
                        }

                        TextField{
                            id:port1voltage1TextInput
                            anchors.left:port1AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port1AdvertizedVoltagesGroup.top
                            anchors.topMargin: 0
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port1voltage1UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port1voltage1TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port1voltage1TextInput.verticalCenter

                        }
                        Slider{
                            id:port1voltage1Slider
                            anchors.left:port1voltage1UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port1voltage1TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port1voltage1Slider.leftPadding
                                    y: port1voltage1Slider.topPadding + port1voltage1Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port1voltage1Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port1voltage1Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port1voltage1Slider.leftPadding + port1voltage1Slider.visualPosition * (port1voltage1Slider.availableWidth - width)
                                    y: port1voltage1Slider.topPadding + port1voltage1Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }


                        }

                        TextField{
                            id:port1voltage2TextInput
                            anchors.left:port1AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port1voltage1TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port1voltage2UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port1voltage2TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port1voltage2TextInput.verticalCenter

                        }

                        Slider{
                            id:port1voltage2Slider
                            anchors.left:port1voltage2UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port1voltage2UnitText.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port1voltage2Slider.leftPadding
                                    y: port1voltage2Slider.topPadding + port1voltage2Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port1voltage2Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port1voltage2Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port1voltage2Slider.leftPadding + port1voltage2Slider.visualPosition * (port1voltage2Slider.availableWidth - width)
                                    y: port1voltage2Slider.topPadding + port1voltage2Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }

                        TextField{
                            id:port1voltage3TextInput
                            anchors.left:port1AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port1voltage2TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port1voltage3UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port1voltage3TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port1voltage3TextInput.verticalCenter

                        }

                        Slider{
                            id:port1voltage3Slider
                            anchors.left:port1voltage3UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port1voltage3TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port1voltage3Slider.leftPadding
                                    y: port1voltage3Slider.topPadding + port1voltage3Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port1voltage3Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port1voltage3Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port1voltage3Slider.leftPadding + port1voltage3Slider.visualPosition * (port1voltage3Slider.availableWidth - width)
                                    y: port1voltage3Slider.topPadding + port1voltage3Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }

                        TextField{
                            id:port1voltage4TextInput
                            anchors.left:port1AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port1voltage3TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port1voltage4UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port1voltage4TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port1voltage4TextInput.verticalCenter

                        }

                        Slider{
                            id:port1voltage4Slider
                            anchors.left:port1voltage4UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port1voltage4TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port1voltage4Slider.leftPadding
                                    y: port1voltage4Slider.topPadding + port1voltage4Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port1voltage4Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port1voltage4Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port1voltage4Slider.leftPadding + port1voltage4Slider.visualPosition * (port1voltage4Slider.availableWidth - width)
                                    y: port1voltage4Slider.topPadding + port1voltage4Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }

                        TextField{
                            id:port1voltage5TextInput
                            anchors.left:port1AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port1voltage4TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port1voltage5UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port1voltage5TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port1voltage5TextInput.verticalCenter

                        }

                        Slider{
                            id:port1voltage5Slider
                            anchors.left:port1voltage5UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port1voltage5TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port1voltage5Slider.leftPadding
                                    y: port1voltage5Slider.topPadding + port1voltage5Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port1voltage5Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port1voltage5Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port1voltage5Slider.leftPadding + port1voltage5Slider.visualPosition * (port1voltage5Slider.availableWidth - width)
                                    y: port1voltage5Slider.topPadding + port1voltage5Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }

                        TextField{
                            id:port1voltage6TextInput
                            anchors.left:port1AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port1voltage5TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port1voltage6UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port1voltage6TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port1voltage6TextInput.verticalCenter

                        }

                        Slider{
                            id:port1voltage6Slider
                            anchors.left:port1voltage6UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port1voltage6TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port1voltage6Slider.leftPadding
                                    y: port1voltage6Slider.topPadding + port1voltage6Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port1voltage6Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port1voltage6Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port1voltage6Slider.leftPadding + port1voltage6Slider.visualPosition * (port1voltage6Slider.availableWidth - width)
                                    y: port1voltage6Slider.topPadding + port1voltage6Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }

                        TextField{
                            id:port1voltage7TextInput
                            anchors.left:port1AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port1voltage6TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port1voltage7UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port1voltage7TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port1voltage7TextInput.verticalCenter

                        }

                        Slider{
                            id:port1voltage7Slider
                            anchors.left:port1voltage7UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port1voltage7TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port1voltage7Slider.leftPadding
                                    y: port1voltage7Slider.topPadding + port1voltage7Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port1voltage7Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port1voltage7Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port1voltage7Slider.leftPadding + port1voltage7Slider.visualPosition * (port1voltage7Slider.availableWidth - width)
                                    y: port1voltage7Slider.topPadding + port1voltage7Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }
                    }
                }

                //--------------------------
                // port 2 settings
                //--------------------------
                Rectangle{
                    id:port2Settings
                    Layout.preferredWidth  : grid.prefWidth(this)
                    Layout.preferredHeight : grid.prefHeight(this)
                    color: "black"

                    NumberAnimation{
                        id: collapsePort2Settings
                        target: port2Settings;
                        property: "Layout.preferredHeight";
                        to: 60;
                        duration: settings.collapseAnimationSpeed
                    }

                    NumberAnimation {
                        id: expandPort2Settings
                        target: port2Settings
                        property: "Layout.preferredHeight";
                        to: grid.prefHeight(port2Settings);
                        duration: settings.collapseAnimationSpeed;
                    }

                    Button{
                        id: port2SettingsDisclosureButton
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.topMargin: 20
                        height: 20//parent.width/20
                        width: 20//parent.width/40
                        checkable: true
                        checked: true
                        background: Rectangle {
                            color: "black"
                        }

                        Image{
                            id:port2DisclosureButtonImage
                            anchors.left:parent.left
                            anchors.leftMargin: 3
                            anchors.top:parent.top
                            height:10
                            width:14
                            source:"./images/icons/showLessIcon.svg"

                            transform: Rotation {
                                id: rotatePort2ButtonImage
                                origin.x: port2DisclosureButtonImage.width/2;
                                origin.y: port2DisclosureButtonImage.height/2;
                                axis { x: 0; y: 0; z: 1 }
                            }

                            NumberAnimation {
                                id:collapsePort2DisclosureIcon
                                running: false
                                loops: 1
                                target: rotatePort2ButtonImage;
                                property: "angle";
                                from: 0; to: 180;
                                duration: 1000;
                            }

                            NumberAnimation {
                                id:expandPort2DisclosureIcon
                                running: false
                                loops: 1
                                target: rotatePort2ButtonImage;
                                property: "angle";
                                from: 180; to: 0;
                                duration: 1000;
                            }
                        }

                        onClicked:{
                            if (checked == true){
                                expandPort2Settings.start();
                                expandPort2DisclosureIcon.start();
                                }
                            else{
                                collapsePort2Settings.start();
                                collapsePort2DisclosureIcon.start()
                              }
                        }

                    }

                    Label{
                        id: port2SettingsLabel
                        text: "Port 2 Settings"
                        font.family: "Helvetica"
                        font.pointSize: mediumFontSize
                        color: "#D8D8D8"
                        anchors.left:parent.left
                        anchors.top:parent.top
                        anchors.leftMargin: 20//parent.width/20
                        anchors.topMargin: 20//parent.height/20
                    }

                    Rectangle{
                        id: port2SettingsSeparator
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: parent.width/20
                        anchors.rightMargin: parent.width/20
                        anchors.top: port2SettingsLabel.bottom
                        anchors.topMargin: port2SettingsLabel.height
                        height: 1
                        color:"#CCCCCC"
                    }

                    Text{
                        id:port2CableCompensationText
                        text:"Cable compensation step:"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        horizontalAlignment: Text.AlignRight
                        color: "#D8D8D8"
                        anchors.right:parent.right
                        anchors.rightMargin: parent.width*.6
                        anchors.top: port2SettingsSeparator.bottom
                        anchors.topMargin: 10

                    }
                    TextField{
                        id:port2CableCompensationTextInput
                        anchors.left:port2CableCompensationText.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: port2CableCompensationText.verticalCenter
                        color:"white"//"#838484"
                        placeholderText:"70"
                        verticalAlignment: TextInput.AlignTop
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        height:15
                        width:30
                        background: Rectangle {
                                implicitWidth: 15
                                implicitHeight: 10
                                color: "#838484"//"#33FFFFFF"
                                border.color: "#838484"
                            }
                    }
                    Text{
                        id:port2CableCompensationUnitText
                        text:"A"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        color: "#D8D8D8"
                        anchors.left:port2CableCompensationTextInput.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: port2CableCompensationText.verticalCenter

                    }

                    Text{
                        id:port2VoltageCompensationText
                        text:"Voltage compensation:"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        horizontalAlignment: Text.AlignRight
                        color: "#D8D8D8"
                        anchors.right:parent.right
                        anchors.rightMargin: parent.width*.6
                        anchors.top: port2CableCompensationText.bottom
                        anchors.topMargin: 10
                    }
                    TextField{
                        id:port2VoltageCompensationTextInput
                        anchors.left:port2VoltageCompensationText.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: port2VoltageCompensationText.verticalCenter
                        color:"white"//"#838484"
                        placeholderText:"7"
                        verticalAlignment: TextInput.AlignTop
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        height:15
                        width:30
                        background: Rectangle {
                                implicitWidth: 15
                                implicitHeight: 10
                                color: "#838484"//"#33FFFFFF"
                                border.color: "#838484"
                            }
                    }
                    Text{
                        id:port2VoltageCompensationUnitText
                        text:"mV"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        color: "#D8D8D8"
                        anchors.left:port2VoltageCompensationTextInput.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: port2VoltageCompensationText.verticalCenter

                    }

                    Text{
                        id:port2MaxPowerText
                        text:"Maximum power output:"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        horizontalAlignment: Text.AlignRight
                        color: "#D8D8D8"
                        anchors.right:parent.right
                        anchors.rightMargin: parent.width*.6
                        anchors.top: port2VoltageCompensationText.bottom
                        anchors.topMargin: 10
                    }

                    ComboBox {
                        id:port2MaxPowerCombo
                         model: ["27", "36", "45","60","100"]
//                        textRole: "key"
//                        model: ListModel {
//                         id:model
//                                ListElement { key: "27"; value: 27 }
//                                ListElement { key: "36"; value: 36 }
//                                ListElement { key: "45"; value: 45 }
//                                ListElement { key: "60"; value: 60 }
//                                ListElement { key: "100"; value: 100 }
//                            }
                        anchors.left:port2MaxPowerText.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: port2MaxPowerText.verticalCenter
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        height:15
                        width:30

                        //this is used by the PopUp to determine what font to use
                        delegate: ItemDelegate {
                                width: port2MaxPowerCombo.width
                                height:15
                                contentItem: Text {
                                    text: modelData
                                    color: highlighted? "#D8D8D8" :"black"
                                    font: port2MaxPowerCombo.font
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked:{
                                    //here's where a click on a new selection should be handled
                                    implementationInterfaceBinding.setMaximumPortPower(2,modelData)
                                    console.log("clicked:", modelData)
                                }

                                highlighted: port2MaxPowerCombo.highlightedIndex === index
                            }

//                        indicator: Canvas {
//                                id: canvas
//                                x: port2MaxPowerCombo.width /*- width*/ - port2MaxPowerCombo.rightPadding
//                                y: port2MaxPowerCombo.topPadding + (port2MaxPowerCombo.availableHeight - height) / 2
//                                width: 12
//                                height: 8
//                                contextType: "2d"

//                                Connections {
//                                    target: port2MaxPowerCombo
//                                    onPressedChanged: canvas.requestPaint()
//                                }

//                                onPaint: {
//                                    context.reset();
//                                    context.moveTo(0, 0);
//                                    context.lineTo(width, 0);
//                                    context.lineTo(width / 2, height);
//                                    context.closePath();
//                                    context.fillStyle = "black";
//                                    context.fill();
//                                }
//                            }

                        background: Rectangle {
                                implicitWidth: 15
                                implicitHeight: 10
                                color: "#838484"
                                border.color: "#838484"
                            }

                        contentItem: Text {
                                leftPadding: 0
                                rightPadding: port2MaxPowerCombo.indicator.width + port2MaxPowerCombo.spacing

                                text: port2MaxPowerCombo.displayText
                                font: port2MaxPowerCombo.font
                                color: port2MaxPowerCombo.pressed ? "#17a81a" : "#D8D8D8"
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                        popup: Popup {
                            y: port2MaxPowerCombo.height - 1
                            width: port2MaxPowerCombo.width *2
                            implicitHeight: contentItem.implicitHeight
                            padding: 1
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            //color: "#D8D8D8"

                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: port2MaxPowerCombo.popup.visible ? port2MaxPowerCombo.delegateModel : null
                                currentIndex: port2MaxPowerCombo.highlightedIndex

                                ScrollIndicator.vertical: ScrollIndicator { }
                            }

                            background: Rectangle {
                                color: "#838484"
                                border.color: "#838484"
                            }
                        }
                    }

                    Text{
                        id:port2MaxPowerUnitText
                        text:"W"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        color: "#D8D8D8"
                        anchors.left:port2MaxPowerCombo.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: port2MaxPowerText.verticalCenter

                    }



                    Text{
                        id:port2MaxCurrentText
                        text:"Maximum current:"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        horizontalAlignment: Text.AlignRight
                        color: "#D8D8D8"
                        anchors.right:parent.right
                        anchors.rightMargin: parent.width*.6
                        anchors.top: port2MaxPowerText.bottom
                        anchors.topMargin: 10
                    }
                    TextField{
                        id:port2MaxCurrentTextInput
                        anchors.left:port2MaxCurrentText.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: port2MaxCurrentText.verticalCenter
                        color:"white"//"#838484"
                        placeholderText:"7"
                        verticalAlignment: TextInput.AlignTop
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        height:15
                        width:30
                        background: Rectangle {
                                implicitWidth: 15
                                implicitHeight: 10
                                color: "#838484"//"#33FFFFFF"
                                border.color: "#838484"
                            }
                    }
                    Text{
                        id:port2MaxCurrentUnitText
                        text:"A"
                        font.family: "helvetica"
                        font.pointSize: smallFontSize
                        color: "#D8D8D8"
                        anchors.left:port2MaxCurrentTextInput.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: port2MaxCurrentText.verticalCenter

                    }

                    //-----------------------------------------------
                    //  advertized voltages group
                    //-----------------------------------------------
                    Rectangle{
                        id:port2AdvertizedVoltagesGroup
                        color:"black"//"#33FFFFFF"
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        anchors.top: port2MaxCurrentText.bottom
                        anchors.topMargin: 10
                        height: 150
                        Text{
                            id:port2AdvertizedVoltagesLabel
                            text:"Advertized Voltages:"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.right:parent.right
                            anchors.rightMargin: parent.width*.6
                            anchors.top: parent.top
                            anchors.topMargin: 0
                        }

                        TextField{
                            id:port2voltage1TextInput
                            anchors.left:port2AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port2AdvertizedVoltagesGroup.top
                            anchors.topMargin: 0
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port2voltage1UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port2voltage1TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port2voltage1TextInput.verticalCenter

                        }
                        Slider{
                            id:port2voltage1Slider
                            anchors.left:port2voltage1UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port2voltage1TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port2voltage1Slider.leftPadding
                                    y: port2voltage1Slider.topPadding + port2voltage1Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port2voltage1Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port2voltage1Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port2voltage1Slider.leftPadding + port2voltage1Slider.visualPosition * (port2voltage1Slider.availableWidth - width)
                                    y: port2voltage1Slider.topPadding + port2voltage1Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }


                        }

                        TextField{
                            id:port2voltage2TextInput
                            anchors.left:port2AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port2voltage1TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port2voltage2UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port2voltage2TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port2voltage2TextInput.verticalCenter

                        }

                        Slider{
                            id:port2voltage2Slider
                            anchors.left:port2voltage2UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port2voltage2UnitText.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port2voltage2Slider.leftPadding
                                    y: port2voltage2Slider.topPadding + port2voltage2Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port2voltage2Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port2voltage2Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port2voltage2Slider.leftPadding + port2voltage2Slider.visualPosition * (port2voltage2Slider.availableWidth - width)
                                    y: port2voltage2Slider.topPadding + port2voltage2Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }

                        TextField{
                            id:port2voltage3TextInput
                            anchors.left:port2AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port2voltage2TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port2voltage3UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port2voltage3TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port2voltage3TextInput.verticalCenter

                        }

                        Slider{
                            id:port2voltage3Slider
                            anchors.left:port2voltage3UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port2voltage3TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port2voltage3Slider.leftPadding
                                    y: port2voltage3Slider.topPadding + port2voltage3Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port2voltage3Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port2voltage3Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port2voltage3Slider.leftPadding + port2voltage3Slider.visualPosition * (port2voltage3Slider.availableWidth - width)
                                    y: port2voltage3Slider.topPadding + port2voltage3Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }

                        TextField{
                            id:port2voltage4TextInput
                            anchors.left:port2AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port2voltage3TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port2voltage4UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port2voltage4TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port2voltage4TextInput.verticalCenter

                        }

                        Slider{
                            id:port2voltage4Slider
                            anchors.left:port2voltage4UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port2voltage4TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port2voltage4Slider.leftPadding
                                    y: port2voltage4Slider.topPadding + port2voltage4Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port2voltage4Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port2voltage4Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port2voltage4Slider.leftPadding + port2voltage4Slider.visualPosition * (port2voltage4Slider.availableWidth - width)
                                    y: port2voltage4Slider.topPadding + port2voltage4Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }

                        TextField{
                            id:port2voltage5TextInput
                            anchors.left:port2AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port2voltage4TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port2voltage5UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port2voltage5TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port2voltage5TextInput.verticalCenter

                        }

                        Slider{
                            id:port2voltage5Slider
                            anchors.left:port2voltage5UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port2voltage5TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port2voltage5Slider.leftPadding
                                    y: port2voltage5Slider.topPadding + port2voltage5Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port2voltage5Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port2voltage5Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port2voltage5Slider.leftPadding + port2voltage5Slider.visualPosition * (port2voltage5Slider.availableWidth - width)
                                    y: port2voltage5Slider.topPadding + port2voltage5Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }

                        TextField{
                            id:port2voltage6TextInput
                            anchors.left:port2AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port2voltage5TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port2voltage6UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port2voltage6TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port2voltage6TextInput.verticalCenter

                        }

                        Slider{
                            id:port2voltage6Slider
                            anchors.left:port2voltage6UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port2voltage6TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port2voltage6Slider.leftPadding
                                    y: port2voltage6Slider.topPadding + port2voltage6Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port2voltage6Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port2voltage6Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port2voltage6Slider.leftPadding + port2voltage6Slider.visualPosition * (port2voltage6Slider.availableWidth - width)
                                    y: port2voltage6Slider.topPadding + port2voltage6Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }

                        TextField{
                            id:port2voltage7TextInput
                            anchors.left:port2AdvertizedVoltagesLabel.right
                            anchors.leftMargin: 5
                            anchors.top: port2voltage6TextInput.bottom
                            anchors.topMargin: 5
                            color:"white"//"#838484"
                            placeholderText:"5"
                            verticalAlignment: TextInput.AlignTop
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            height:15
                            width:20
                            background: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 10
                                    color: "#838484"//"#33FFFFFF"
                                    border.color: "#838484"
                                }
                        }

                        Text{
                            id:port2voltage7UnitText
                            text:"V"
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                            anchors.left:port2voltage7TextInput.right
                            anchors.leftMargin: 5
                            anchors.verticalCenter: port2voltage7TextInput.verticalCenter

                        }

                        Slider{
                            id:port2voltage7Slider
                            anchors.left:port2voltage7UnitText.right
                            anchors.leftMargin: 5
                            anchors.right:parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: port2voltage7TextInput.verticalCenter
                            height:10
                            from: 5
                            to:20
                            value:5
                            stepSize: 0.0
                            //the trail of the slider
                            background: Rectangle {
                                    x: port2voltage7Slider.leftPadding
                                    y: port2voltage7Slider.topPadding + port2voltage7Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 200
                                    implicitHeight: 2
                                    width: port2voltage7Slider.availableWidth
                                    height: implicitHeight
                                    radius: 2
                                    color: "#bdbebf"

                                    //the portion of the trail to the left of the thumb
                                    Rectangle {
                                        width: port2voltage7Slider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#0078D7"
                                        radius: 2
                                    }
                                }

                            //the thumb of the slider
                                handle: Rectangle {
                                    x: port2voltage7Slider.leftPadding + port2voltage7Slider.visualPosition * (port2voltage7Slider.availableWidth - width)
                                    y: port2voltage7Slider.topPadding + port2voltage7Slider.availableHeight / 2 - height / 2
                                    implicitWidth: 10
                                    implicitHeight: 10
                                    radius: 5
                                    color: "black"
                                    border.color: "#0078D7"
                                    border.width: 2
                                }
                        }
                    }
                }


            }
        } //settings rectangle

        Rectangle {
            id:boardRect
            //columns 0 and 1, both rows
            Layout.column: 1
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 2
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            z:1     //set the z level higher so connectors go behind the board
            color:"black"
            AdvancedBoard{}

            Text{
                id:usbPDText
                text:"USB-PD Dual"
                font.family: "helvetica"
                font.pointSize: extraLargeFontSize
                color:"#D8D8D8"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: parent.height/20
            }
            Text{
                text:"Advanced Controls"
                font.family: "helvetica"
                font.pointSize: largeFontSize
                color:"#D8D8D8"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: usbPDText.bottom
                anchors.topMargin: usbPDText.height/4
            }
        } //board rectangle

        //----------------------------------------
        //

        Rectangle {
            id:graphs
            //column 2, 2 rows
            Layout.column: 2
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 2
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true

            color: "yellow"

            GridLayout{
                id: graphGrid
                columns: 2
                rows: 3
                anchors {fill:parent}
                columnSpacing: 0
                rowSpacing: 0

                property double colMulti : graphGrid.width / graphGrid.columns
                property double rowMulti : graphGrid.height / graphGrid.rows

                function prefWidth(item){
                    return colMulti * item.Layout.columnSpan
                }
                function prefHeight(item){
                    return rowMulti * item.Layout.rowSpan
                }
                Rectangle{
                    id:port1VoltageAndCurrentRect
                    Layout.column: 0
                    Layout.columnSpan: 1
                    Layout.row: 0
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port1VoltageAndCurrentHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 1 VOLTAGE AND CURRENT"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port1VoltageAndCurrent
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port1VoltageAndCurrentHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }
                Rectangle{
                    id:port2VoltageAndCurrentRect
                    Layout.column: 1
                    Layout.columnSpan: 1
                    Layout.row: 0
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port2VoltageAndCurrentHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 2 VOLTAGE AND CURRENT"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port2VoltageAndCurrent
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port2VoltageAndCurrentHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }

                Rectangle{
                    id:port1PowerRect
                    Layout.column: 0
                    Layout.columnSpan: 1
                    Layout.row: 1
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port1PowerHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 1 POWER"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port1Power
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port1PowerHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }
                Rectangle{
                    id:port2PowerRect
                    Layout.column: 1
                    Layout.columnSpan: 1
                    Layout.row: 1
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port2PowerHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 2 POWER"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port2Power
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port2PowerHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }
                Rectangle{
                    id:port1TemperatureRect
                    Layout.column: 0
                    Layout.columnSpan: 1
                    Layout.row: 2
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port1TemperatureHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 1 TEMPERATURE"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port1Temperature
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port1TemperatureHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }

                Rectangle{
                    id:port2TemperatureRect
                    Layout.column: 1
                    Layout.columnSpan: 1
                    Layout.row: 2
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port2TemperatureHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 2 TEMPERATURE"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port2Temperature
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port2TemperatureHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }

            }
        }

            Rectangle {
                id:message
                //row 3, columns 2 and 3
                Layout.column: 1
                Layout.columnSpan: 2
                Layout.row: 2
                Layout.rowSpan: 1
                Layout.preferredWidth  : grid.prefWidth(this)
                Layout.preferredHeight : grid.prefHeight(this)
                Layout.fillWidth:true
                Layout.fillHeight:true

                RowLayout{
                    anchors.fill:parent
                    spacing:-1
                    Rectangle{
                        id:activeFaults
                        Layout.preferredWidth:parent.width/3
                        Layout.preferredHeight:parent.height
                        color:"black"
                        border.color:"black"

                        Label{
                            id: activeFaultsLabel
                            text: "Active Faults"
                            font.family: "Helvetica"
                            font.pointSize: mediumFontSize
                            color: "#D8D8D8"
                            anchors.left:parent.left
                            anchors.top:parent.top
                            anchors.leftMargin: parent.width/20
                            anchors.topMargin: parent.height/20
                            }

                        Rectangle{
                           id:activeFaultsSeparator
                           anchors.left: parent.left
                           anchors.right: parent.right
                           anchors.leftMargin: parent.width/20
                           anchors.rightMargin: parent.width/20
                           anchors.top: activeFaultsLabel.bottom
                           anchors.topMargin: activeFaultsLabel.height
                           height: 1
                           color:"#CCCCCC"
                        }

                        Rectangle{
                            id:activeFaultsListBackground
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: activeFaultsSeparator.bottom
                            anchors.topMargin: parent.height/20
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/20
                            color: "#2B2B2B"
                        }

                        ListModel {
                            id:activeFaultsListModel
                            ListElement {
                                fault: "Port 1 Temperature: 71°C"
                            }
                        }

                        ListView {
                            id:activeFaultsListView
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: activeFaultsSeparator.bottom
                            anchors.topMargin: parent.height/20
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/20

                            model: activeFaultsListModel

                            delegate: Text {
                                text: fault
                                color: "orangered"
                                font.pointSize: smallFontSize
                            }

                        }

                    } //Active Fonts box

                    Rectangle{
                        id: faultHistory
                        Layout.preferredWidth:parent.width/3
                        Layout.preferredHeight:parent.height
                        color:"black"
                        border.color:"black"



                        Label{
                            id: faultHistoryLabel
                            text: "Fault History"
                            font.family: "Helvetica"
                            font.pointSize: mediumFontSize
                            color: "#D8D8D8"
                            anchors.left:parent.left
                            anchors.top:parent.top
                            anchors.leftMargin: parent.width/20
                            anchors.topMargin: parent.height/20
                            }

                        Rectangle{
                           id: faultHistorySeparator
                           anchors.left: parent.left
                           anchors.right: parent.right
                           anchors.leftMargin: parent.width/20
                           anchors.rightMargin: parent.width/20
                           anchors.top: faultHistoryLabel.bottom
                           anchors.topMargin: faultHistoryLabel.height
                           height: 1
                           color:"#CCCCCC"
                        }

                        Rectangle{
                            id:faultHistoryListBackground
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: faultHistorySeparator.bottom
                            anchors.topMargin: parent.height/20
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/20
                            color: "#2B2B2B"
                        }

                        ListModel {
                            id:faultHistoryListModel
                            ListElement {
                                fault: "Port 1 Temperature: 71°C"
                            }
                        }

                        ListView {
                            id:faultHistoryListView
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: faultHistorySeparator.bottom
                            anchors.topMargin: parent.height/20
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/20

                            model: faultHistoryListModel

                            delegate: Text {
                                text: fault
                                color: "#D8D8D8"
                                font.pointSize: smallFontSize
                            }
                        }


                    }
                    Rectangle{
                        id: usbPdMessages
                        Layout.preferredWidth:parent.width/3 +1
                        Layout.preferredHeight:parent.height
                        color:"black"
                        border.color:"black"

                        Label{
                            id: usbPDMessagesLabel
                            text: "USB-PD Messages"
                            font.family: "Helvetica"
                            font.pointSize: mediumFontSize
                            color: "#D8D8D8"
                            anchors.left:parent.left
                            anchors.top:parent.top
                            anchors.leftMargin: parent.width/20
                            anchors.topMargin: parent.height/20
                            }

                        Rectangle{
                           id: usbPDMessagesSeparator
                           anchors.left: parent.left
                           anchors.right: parent.right
                           anchors.leftMargin: parent.width/20
                           anchors.rightMargin: parent.width/20
                           anchors.top: usbPDMessagesLabel.bottom
                           anchors.topMargin: usbPDMessagesLabel.height
                           height: 1
                           color:"#CCCCCC"
                        }

                        Label{
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: usbPDMessagesSeparator.bottom
                            anchors.topMargin: parent.height/20
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/20
                            background: Rectangle {
                                color: "#2B2B2B"
                            }
                            text: "Capabilities request"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                        }
                    }
                }
            }
    }   //grid layout



}
