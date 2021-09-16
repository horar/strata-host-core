/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    width: contentColumn.width
    height: editEnabledCheckBox.y + editEnabledCheckBox.height

    Column {
        id: contentColumn
        SGAlignedLabel {
            id: demoLabel
            target: infoBox
            text: "Default Info Box"
            fontSizeMultiplier: 1.3
            SGInfoBox {
                id: infoBox
                text: data.stream                           // String to this to be displayed in box
                // Optional configuration:
                fontSizeMultiplier: 1.3                     // Default: 1.0 (affects text and unit)
                unit: ""                                   // Default: ""
                width: 100
                // boxColor: "lightgreen"                      // Default: "#eeeeee" (light gray)
                // height: 26                               // Default: 26 * fontSizeMultiplier
                // horizontalAlignment: Text.AlignHCenter   // Default: Text.AlignRight (sets alignment of text in box)
                // textColor: "black"                       // Default: "black" (affects text and unit)

                // boxBorderColor: "green"                  // Default: "#cccccc" (light gray)
                // boxBorderWidth: 1                        // Default: 1 (assign 0 for no border)
                // unitFont                                 // Use to specify font overrides for the unit (ie: 'unitFont.family: Fonts.franklinGothicBold')
                // boxFont                                  // Use to specify font overrides for the box text (ie: 'boxFont.family: Fonts.franklinGothicBold')
            }
        }

        SGAlignedLabel {
            id: demoLabel2
            target: customizeInfoBox
            text: "Customize Info Box"
            fontSizeMultiplier: 1.3
            SGInfoBox {
                id: customizeInfoBox
                text: data.stream                           // String to this to be displayed in box
                // Optional configuration:
                fontSizeMultiplier: 1.3                     // Default: 1.0 (affects text and unit)
                unit: "unit"                                   // Default: ""
                width: 100
                boxColor: "lightgreen"                      // Default: "#eeeeee" (light gray)
                // height: 26                               // Default: 26 * fontSizeMultiplier
                // horizontalAlignment: Text.AlignHCenter   // Default: Text.AlignRight (sets alignment of text in box)
                // textColor: "black"                       // Default: "black" (affects text and unit)
                // boxBorderColor: "green"                  // Default: "#cccccc" (light gray)
                // boxBorderWidth: 1                        // Default: 1 (assign 0 for no border)
                // unitFont                                 // Use to specify font overrides for the unit (ie: 'unitFont.family: Fonts.franklinGothicBold')
                // boxFont                                  // Use to specify font overrides for the box text (ie: 'boxFont.family: Fonts.franklinGothicBold')
            }
        }

        // Sends demo data stream to infoBox
        Timer {
            id: data
            property real stream
            property real count: 0
            interval: 100
            running: true
            repeat: true
            onTriggered: {
                count += interval;
                stream = (Math.sin(count/500)*3+10).toFixed(2);
            }
        }
    }

    SGCheckBox {
        id: editEnabledCheckBox
        anchors {
            top: contentColumn.bottom
            topMargin: 20
        }
        text: "Everything enabled"
        checked: true
        onCheckedChanged: {
            console.info(checked)
            if (editEnabledCheckBox.checked) {
                data.start()
                infoBox.opacity = 1.0
                customizeInfoBox.opacity = 1.0
            }
            else {
                data.stop()
                infoBox.opacity = 0.5
                customizeInfoBox.opacity = 0.5
            }
        }
    }
}
