import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.9
import tech.strata.sgwidgets 1.0

Window {
    id: window
    visible: true
    height: 600
    width: 800

    SGAlignedLabel {
        id: label
        target: exampleControl
        text: "<b>Label"
        anchors.centerIn: parent

        // Optional Configuration:
        // alignment: SGLabel.SideLeftTop      // Default: SGLabel.SideTopLeft
        // margin: 5                           // Default: 5 (adjust margin between control and label)
        // hasAlternativeColor: false          // Default: false (true causes alternative color to be used)
        // implicitColor: "black"              // Default: "black"
        // alternativeColor: "white"           // Default: "white"
        // fontSizeMultiplier: 1.0             // Default: 1.0
        // overrideLabelWidth: 300             // hard codes a label width which allows easy alignment of controls when label is aligned to SGLabel.SideLeft

        SGHueSlider {
            id: exampleControl
            width: 300
        }
    }

    // Notes:
    // Label wraps/contains target object (which itself can be a container of other objects)
    // Height/width of label are in addition to the target (do not set these)
    // Alignment names are in reference to the corners/sides of the target
    /* Alignment enums are:
        SGLabel.CornerTopLeft
        SGLabel.CornerBottomLeft
        SGLabel.CornerTopRight
        SGLabel.CornerBottomRight

        SGLabel.SideLeftTop
        SGLabel.SideLeftCenter
        SGLabel.SideLeftBottom

        SGLabel.SideRightTop
        SGLabel.SideRightCenter
        SGLabel.SideRightBottom

        SGLabel.SideTopLeft
        SGLabel.SideTopCenter
        SGLabel.SideTopRight

        SGLabel.SideBottomLeft
        SGLabel.SideBottomCenter
        SGLabel.SideBottomRight
     */
}
