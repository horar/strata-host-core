import QtQuick 2.0
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0

Item {
    id: root
    width: contentColumn.width
    height: contentColumn.height

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

    Column {
        id: contentColumn
        spacing: 10


        SGAlignedLabel {
            id: demoTopLabel
            target: infoBoxSideTopCenter
            alignment: SGAlignedLabel.SideTopCenter
            text: "Top Label"
            fontSizeMultiplier: 1.3
            SGInfoBox {
                id: infoBoxSideTopCenter
                fontSizeMultiplier: 1.3
                width: 100

            }
        }

        SGAlignedLabel {
            id: demoLeftLabel
            target: infoBoxLeftCenterLabel
            alignment: SGAlignedLabel.SideLeftCenter
            text: "Left Label"
            fontSizeMultiplier: 1.3

            SGInfoBox {
                id: infoBoxLeftCenterLabel
                fontSizeMultiplier: 1.3
                width: 100

            }
        }

        SGAlignedLabel {
            id: demoRightLabel
            target: infoBoxSideRightCenter
            alignment: SGAlignedLabel.SideRightCenter
            text: "Right Label"
            fontSizeMultiplier: 1.3

            SGInfoBox {
                id: infoBoxSideRightCenter
                fontSizeMultiplier: 1.3
                width: 100

            }
        }

        SGAlignedLabel {
            id: demoBottomLabel4
            target: infoBoxSideBottomCenter
            alignment: SGAlignedLabel.SideBottomCenter
            text: "Bottom Label"
            fontSizeMultiplier: 1.3

            SGInfoBox {
                id: infoBoxSideBottomCenter
                fontSizeMultiplier: 1.3
                width: 100

            }
        }
    }
}
