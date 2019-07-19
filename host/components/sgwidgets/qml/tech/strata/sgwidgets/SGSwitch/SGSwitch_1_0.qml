import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

RowLayout {
    id: switchRow
    spacing: root.labelsInside ? 0 : 5
    clip: true
    opacity: enabled ? 1 : 0.3

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

    property alias pressed: switchRoot.pressed
    property alias down: switchRoot.down
    property alias checked: switchRoot.checked
    property alias checkedLabel: checkedOuterText.text
    property alias uncheckedLabel: uncheckedOuterText.text
    property alias grooveFillColor: grooveFill.color
    property alias grooveColor: groove.color
    
    SGText {
        id: uncheckedOuterText
        visible: text === "" ? false : !switchRow.labelsInside
        text: ""
        color: switchRow.textColor
        fontSizeMultiplier: switchRow.fontSizeMultiplier
        elide: Text.ElideRight
        Layout.fillWidth: true
        Layout.maximumWidth: uncheckedOuterTextHelper.width+1
        
        TextMetrics {
            id: uncheckedOuterTextHelper
            // saves base contentWidth since elide changes it
            text: uncheckedOuterText.text
            font.family: uncheckedOuterText.font.family
            font.pixelSize: uncheckedOuterText.font.pixelSize
        }
    }
    
    Switch {
        id: switchRoot
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.minimumWidth: height
        implicitWidth: height * 1.33 + (switchRow.labelsInside ? Math.max(uncheckedInnerTextHelper.width, checkedInnerTextHelper.width) : height)
        implicitHeight: 25 * fontSizeMultiplier
        padding: 0
        
        property real visualPositionCopy: visualPosition  // Necessary since VP is read-only and we want to manipulate its speed behavior below
        
        Behavior on visualPositionCopy {
            enabled: switchRoot.pressed ? false : true
            NumberAnimation { duration: 100 }
        }
        
        onReleased: switchRow.released()
        onCanceled: switchRow.canceled()
        onClicked: switchRow.clicked()
        onToggled: switchRow.toggled()
        onPressed: switchRow.press()
        onPressAndHold: switchRow.pressAndHold()
        
        indicator: Rectangle {
            id: groove
            width: switchRoot.width
            height: switchRoot.height
            radius: height/2
            color: "#B3B3B3"
            
            SGText {
                id: uncheckedInnerText
                visible: uncheckedLabel === "" ? false : switchRow.labelsInside
                color: switchRow.textColor
                anchors {
                    verticalCenter: groove.verticalCenter
                    right: groove.right
                    rightMargin: groove.height/4
                    left: groove.left
                    leftMargin: groove.height
                }
                fontSizeMultiplier: switchRow.fontSizeMultiplier
                text: switchRow.uncheckedLabel
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight

                TextMetrics {
                    id: uncheckedInnerTextHelper
                    // saves base contentWidth since elide changes it
                    text: uncheckedInnerText.text
                    font.family: uncheckedInnerText.font.family
                    font.pixelSize: uncheckedInnerText.font.pixelSize
                }
            }
            
            Rectangle {
                id: grooveFill
                visible: width === handle.width ? false : true
                width: handle.x + handle.width
                height: handle.height
                color: "#0cf"
                radius: handle.radius
                clip: true
                
                SGText {
                    id: checkedInnerText
                    visible: checkedLabel === "" ? false : switchRow.labelsInside
                    color: switchRow.textColor
                    anchors {
                        verticalCenter: grooveFill.verticalCenter
                        left: grooveFill.left
                        leftMargin: grooveFill.height/4
                        right: grooveFill.right
                        rightMargin: grooveFill.height
                    }
                    fontSizeMultiplier: switchRow.fontSizeMultiplier
                    text: switchRow.checkedLabel
                    elide: Text.ElideRight
                    horizontalAlignment: Text.Alignleft

                    TextMetrics {
                        id: checkedInnerTextHelper
                        // saves base contentWidth since elide changes it
                        text: checkedInnerText.text
                        font.family: checkedInnerText.font.family
                        font.pixelSize: checkedInnerText.font.pixelSize
                    }
                }
            }
            
            Rectangle {
                id: handle
                x: ((switchRoot.visualPositionCopy * switchRoot.width) + (1-switchRoot.visualPositionCopy) * width) - width
                width: switchRoot.height
                height: width
                radius: height/2
                color: switchRow.down ? colorMod(switchRow.handleColor, 1.1) : switchRow.handleColor
                border.color: switchRow.checked ? colorMod(switchRow.grooveFillColor, 1.5) : colorMod(switchRow.grooveColor, 1.5)
            }
        }
    }
    
    SGText {
        id: checkedOuterText
        visible: text === "" ? false : !switchRow.labelsInside
        text: ""
        color: switchRow.textColor
        fontSizeMultiplier: switchRow.fontSizeMultiplier
        elide: Text.ElideRight
        Layout.fillWidth: true
        Layout.maximumWidth: checkedOuterTextHelper.width+1
        
        TextMetrics {
            id: checkedOuterTextHelper
            // saves base contentWidth since elide changes it
            text: checkedOuterText.text
            font.family: checkedOuterText.font.family
            font.pixelSize: checkedOuterText.font.pixelSize
        }
    }
    
    
    // Lighten or darken a color based on a factor
    function colorMod (color, factor) {
        return Qt.rgba(color.r/factor, color.g/factor, color.b/factor, 1 )
    }
}
