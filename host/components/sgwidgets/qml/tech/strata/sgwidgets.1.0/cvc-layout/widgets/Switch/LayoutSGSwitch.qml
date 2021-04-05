import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {

    // pass through all properties
    signal released()
    signal canceled()
    signal clicked()
    signal toggled()
    signal press()
    signal pressAndHold()

    property real fontSizeMultiplier: 1.0
    property color handleColor: "white"
    property color textColor: labelsInside ? "white" : "black"
    property bool labelsInside: true

    property alias pressed: swicthObject.pressed
    property alias down: swicthObject.down
    property alias checked: swicthObject.checked
    property alias checkedLabel: swicthObject.checkedLabel
    property alias uncheckedLabel: swicthObject.uncheckedLabel
    property alias grooveFillColor: swicthObject.grooveFillColor
    property alias grooveColor: swicthObject.grooveColor


    SGSwitch {
        id: swicthObject
        fontSizeMultiplier: parent.fontSizeMultiplier
        labelsInside: parent.labelsInside
        textColor: parent.textColor
        handleColor: parent.handleColor

        onReleased: parent.released()
        onCanceled: parent.canceled()
        onClicked: parent.clicked()
        onToggled: parent.toggled()
        onPressAndHold: parent.pressAndHold()

        //elide: Text.ElideRight
        // wrapMode: Text.Wrap
        //  text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
    }
}

