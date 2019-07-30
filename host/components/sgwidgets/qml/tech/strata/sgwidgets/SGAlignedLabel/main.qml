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
        // alignment: SGAlignedLabel.SideLeftTop    // Default: SGAlignedLabel.SideTopLeft
        // margin: 5                                // Default: 5 (adjust margin between control and label)
        // hasAlternativeColor: false               // Default: false (true causes alternative color to be used)
        // implicitColor: "black"                   // Default: "black"
        // alternativeColor: "white"                // Default: "white"
        // fontSizeMultiplier: 1.0                  // Default: 1.0
        // horizontalAlignment: Text.AlignLeft      // Default: follows alignment left/right/center but can be overridden
        // overrideLabelWidth: 300                  // hard codes a label width which allows easy alignment of controls when label is aligned to SGAlignedLabel.SideLeft
        // font: {}                                 // allows setting the font properties manually (ie: 'font.bold: true')

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
        SGAlignedLabel.CornerTopLeft
        SGAlignedLabel.CornerBottomLeft
        SGAlignedLabel.CornerTopRight
        SGAlignedLabel.CornerBottomRight

        SGAlignedLabel.SideLeftTop
        SGAlignedLabel.SideLeftCenter
        SGAlignedLabel.SideLeftBottom

        SGAlignedLabel.SideRightTop
        SGAlignedLabel.SideRightCenter
        SGAlignedLabel.SideRightBottom

        SGAlignedLabel.SideTopLeft
        SGAlignedLabel.SideTopCenter
        SGAlignedLabel.SideTopRight

        SGAlignedLabel.SideBottomLeft
        SGAlignedLabel.SideBottomCenter
        SGAlignedLabel.SideBottomRight
     */
}
