/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQml 2.12

import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.sgwidgets 1.0
import tech.strata.sglayout 1.0
import tech.strata.commoncpp 1.0
import QtTest 1.1

UIBase { // start_uibase

    // ======================== General Settings ======================== //

    columnCount: 30
    rowCount: 50

    // ======================== Aliases ======================== //

    // ======================== UI Initialization ======================== //

    Component.onCompleted: {

        // ------------------------ Help Messages ------------------------ //

        // Section Name
        Help.registerTarget(a_toggle_help, "Toggle help message.", 0, "AdvancedControlHelp")
        Help.registerTarget(a_slider_help, "Slider help message.", 1, "AdvancedControlHelp")
        Help.registerTarget(a_infobox_integer_help, "InfoBox Integer help message.", 2, "AdvancedControlHelp")
        Help.registerTarget(a_infobox_double_help, "InfoBox Double help message.", 3, "AdvancedControlHelp")
        Help.registerTarget(a_infobox_string_help, "InfoBox String help message.", 4, "AdvancedControlHelp")
        Help.registerTarget(a_combobox_help, "ComboBox help message.", 5, "AdvancedControlHelp")
        // Save and Load Parameters
        Help.registerTarget(a_save_load_parameters_help, "The parameters on this tab and/or other tabs can be saved to disk and recalled for flexibility testing with motors, loads, etc. that have different specifications. Enter a name for the parameter set and click Save to write to disk. This will place the parameter set into the combo box.\n\nTo load parameters, select the desired parameter set in the combo box and click Load to recall the parameters and automatically configure the motor controller. The motor may need to be re-enabled if already running to apply parameters.\n\nTo remove parameters, select the desired parameter set to remove from the combo box and click Delete.\n\nThese parameters are saved as a .json files in '%APPDATA%\\Roaming\\ON Semiconductor\\Strata Developer Studio\\settings' directory and can be transferred between PCs if desired.\n\nThere are built in parameters included that can be recalled. The built in parameters cannot be deleted.", 6, "AdvancedControlHelp")

        // -------------- Request Control Properties -------------- //
        // The firmware should respond with all control properties to populate the UI elements
        platformInterface.commands.control_props.send()

        // -------------- Other Startup Tasks -------------- //
        // Such as synchronizing the UI and firmware

    }

    // ======================== UI Objects ======================== //

    // -------- Title and Subtitle -------- //

    LayoutText { // start_8695e
        id: a_title
        layoutInfo.uuid: "8695e"
        layoutInfo.columnsWide: 28
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 0

        text: platformInterface.notifications.title.caption
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#000000"
    } // end_8695e

    LayoutText { // start_bb4f0
        id: a_subtitle
        layoutInfo.uuid: "bb4f0"
        layoutInfo.columnsWide: 28
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 2

        text: platformInterface.notifications.subtitle.caption
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#7f7f7f"
    } // end_bb4f0

    // -------- Section Header and Divider -------- //

    LayoutText { // start_99acd
        id: section_header
        layoutInfo.uuid: "99acd"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 6

        text: "Section Name"
        fontSizeMode: Text.Fit
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter
        color: "#000000"
    } // end_99acd

    LayoutDivider { // start_578da
        id: section_divider
        layoutInfo.uuid: "578da"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 7
        thickness: 2
    } // end_578da

    // -------- Toggle -------- //

    LayoutSGSwitch { // start_d68f2
        id: a_toggle
        layoutInfo.uuid: "d68f2"
        layoutInfo.columnsWide: 2
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 7
        layoutInfo.yRows: 9

        checkedLabel: platformInterface.notifications.toggle.values.index_0
        uncheckedLabel: platformInterface.notifications.toggle.values.index_1
        labelsInside: true

        checked: platformInterface.notifications.toggle.value
        // states = 1 not applicable as enabled changes opacity
        enabled: !Boolean(platformInterface.notifications.toggle.states.index_0)

        onToggled: {
            console.log("Toggle switched:", checked)
            platformInterface.notifications.toggle.value = checked
            platformInterface.commands.toggle.update(checked)
        }

    } // end_d68f2

    LayoutText { // start_65728
        id: a_toggle_caption
        layoutInfo.uuid: "65728"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 9

        text: platformInterface.notifications.toggle.caption // + " (" + platformInterface.notifications.toggle.unit + ")"
        // states = 1 not applicable as enabled changes opacity
        opacity: !Boolean(platformInterface.notifications.toggle.states.index_0) ? 1 : 0.5

        fontSizeMode: Text.Fit
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter
    } // end_65728

    LayoutItem { // start_8991c
        id: a_toggle_help
        layoutInfo.uuid: "8991c"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 9
    } // end_8991c

    // -------- Slider -------- //

    LayoutSGSlider { // start_b8761
        id: a_slider
        layoutInfo.uuid: "b8761"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 3
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 13

        value: platformInterface.notifications.slider.value
        from: platformInterface.notifications.slider.scales.index_1
        to: platformInterface.notifications.slider.scales.index_0
        stepSize: platformInterface.notifications.slider.scales.index_2
        // states = 1 not applicable as enabled changes opacity
        enabled: !Boolean(platformInterface.notifications.slider.states.index_0)

        live: false
        inputBox.readOnly: true

        onUserSet: {
            console.log("Slider value set:", value)
            platformInterface.notifications.slider.value = value
            platformInterface.commands.slider.update(a_slider.value)
        }
    } // end_b8761

    LayoutText { // start_01fc5
        id: a_slider_caption
        layoutInfo.uuid: "01fc5"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 12

        text: platformInterface.notifications.slider.caption  + " (" + platformInterface.notifications.slider.unit + ")"
        // states = 1 not applicable as enabled changes opacity
        opacity: !Boolean(platformInterface.notifications.slider.states.index_0) ? 1 : 0.5

        fontSizeMode: Text.Fit
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter
    } // end_01fc5

    LayoutItem { // start_1e325
        id: a_slider_help
        layoutInfo.uuid: "1e325"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 4
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 12
    } // end_1e325

    // -------- InfoBox Integer -------- //

    LayoutSGInfoBox { // start_61e5b
        id: a_infobox_integer
        layoutInfo.uuid: "61e5b"
        layoutInfo.columnsWide: 2
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 7
        layoutInfo.yRows: 17

        text: platformInterface.notifications.infobox_integer.value
        readOnly: Boolean(platformInterface.notifications.infobox_integer.states.index_0)
        opacity: platformInterface.notifications.infobox_integer.states.index_0 === 2 ? 0.5 : 1

        validator: IntValidator {
            bottom: 0
            top: 10000
        }

        onEditingFinished : {
            console.log("InfoBox edit finished:", text)
            platformInterface.notifications.infobox_integer.value = Number(text)
            platformInterface.commands.infobox_integer.update(Number(text))
        }

    } // end_61e5b

    LayoutText { // start_bf582
        id: a_infobox_integer_caption
        layoutInfo.uuid: "bf582"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 17

        text: platformInterface.notifications.infobox_integer.caption  + " (" + platformInterface.notifications.infobox_integer.unit + ")"
        opacity: platformInterface.notifications.infobox_integer.states.index_0 === 2 ? 0.5 : 1

        fontSizeMode: Text.Fit
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter

    } // end_bf582

    LayoutItem { // start_a9997
        id: a_infobox_integer_help
        layoutInfo.uuid: "a9997"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 17
    } // end_a9997

    // -------- InfoBox Double -------- //

    LayoutSGInfoBox { // start_4d8a5
        id: a_infobox_double
        layoutInfo.uuid: "4d8a5"
        layoutInfo.columnsWide: 2
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 7
        layoutInfo.yRows: 20

        text: platformInterface.notifications.infobox_double.value
        readOnly: Boolean(platformInterface.notifications.infobox_double.states.index_0)
        opacity: platformInterface.notifications.infobox_double.states.index_0 === 2 ? 0.5 : 1

        validator: DoubleValidator {
            bottom: 0
            top: 10000
            decimals: 2
        }

        onEditingFinished : {
            console.log("InfoBox edit finished:", text)
            platformInterface.notifications.infobox_double.value = Number(text)
            platformInterface.commands.infobox_double.update(Number(text))
        }

    } // end_4d8a5

    LayoutText { // start_4d476
        id: a_infobox_double_caption
        layoutInfo.uuid: "4d476"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 20

        text: platformInterface.notifications.infobox_double.caption  + " (" + platformInterface.notifications.infobox_double.unit + ")"
        opacity: platformInterface.notifications.infobox_double.states.index_0 === 2 ? 0.5 : 1

        fontSizeMode: Text.Fit
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter

    } // end_4d476

    LayoutItem { // start_48507
        id: a_infobox_double_help
        layoutInfo.uuid: "48507"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 20
    } // end_48507

    // -------- InfoBox String -------- //

    LayoutSGInfoBox { // start_124d2
        id: a_infobox_string
        layoutInfo.uuid: "124d2"
        layoutInfo.columnsWide: 2
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 7
        layoutInfo.yRows: 23

        text: platformInterface.notifications.infobox_string.value
        readOnly: Boolean(platformInterface.notifications.infobox_string.states.index_0)
        opacity: platformInterface.notifications.infobox_string.states.index_0 === 2 ? 0.5 : 1

        // No validator required for string

        onEditingFinished : {
            console.log("InfoBox edit finished:", text)
            platformInterface.notifications.infobox_string.value = text
            platformInterface.commands.infobox_string.update(text)
        }

    } // end_124d2

    LayoutText { // start_72d28
        id: a_infobox_string_caption
        layoutInfo.uuid: "72d28"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 23

        text: platformInterface.notifications.infobox_string.caption  + " (" + platformInterface.notifications.infobox_string.unit + ")"
        opacity: platformInterface.notifications.infobox_string.states.index_0 === 2 ? 0.5 : 1

        fontSizeMode: Text.Fit
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter

    } // end_72d28

    LayoutItem { // start_002e6
        id: a_infobox_string_help
        layoutInfo.uuid: "002e6"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 23
    } // end_002e6

    // -------- ComboBox -------- //

    LayoutSGComboBox { // start_f5402
        id: a_combobox
        layoutInfo.uuid: "f5402"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 27

        model: [
            platformInterface.notifications.combobox.values.index_0,
            platformInterface.notifications.combobox.values.index_1,
            platformInterface.notifications.combobox.values.index_2
        ]
        currentIndex: platformInterface.notifications.combobox.value
        // states = 1 not applicable as enabled changes opacity
        enabled: !Boolean(platformInterface.notifications.combobox.states.index_0)

        onActivated: {
            console.log("ComboBox activated:", currentIndex, currentText)
            platformInterface.notifications.combobox.value = currentIndex
            platformInterface.commands.combobox.update(currentIndex)
        }
    } // end_f5402

    LayoutText { // start_b10f9
        id: a_combobox_caption
        layoutInfo.uuid: "b10f9"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 26

        text: platformInterface.notifications.combobox.caption //+ " (" + platformInterface.notifications.combobox.unit + ")"
        // states = 1 not applicable as enabled changes opacity
        opacity: !Boolean(platformInterface.notifications.combobox.states.index_0) ? 1 : 0.5

        fontSizeMode: Text.Fit
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter
    } // end_b10f9

    LayoutItem { // start_26a27
        id: a_combobox_help
        layoutInfo.uuid: "26a27"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 3
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 26
    } // end_26a27

    // ======================== Save and Load Parameters ======================== //

    // This function will load settings from the stored .json configurations into the platform interface
    function loadSettings(config) {
        if (config.hasOwnProperty('toggle')) {
            platformInterface.notifications.toggle.caption = config.toggle.caption
            platformInterface.notifications.toggle.scales.index_0 = config.toggle.scales[0]
            platformInterface.notifications.toggle.scales.index_1 = config.toggle.scales[1]
            platformInterface.notifications.toggle.scales.index_2 = config.toggle.scales[2]
            platformInterface.notifications.toggle.states.index_0 = config.toggle.states[0]
            platformInterface.notifications.toggle.value = config.toggle.value
            platformInterface.notifications.toggle.values.index_0 = config.toggle.values[0]
            platformInterface.notifications.toggle.values.index_1 = config.toggle.values[1]
            platformInterface.notifications.toggle.unit = config.toggle.unit
            platformInterface.commands.toggle.update(platformInterface.notifications.toggle.value)
        }
        if (config.hasOwnProperty('slider')) {
            platformInterface.notifications.slider.caption = config.slider.caption
            platformInterface.notifications.slider.scales.index_0 = config.slider.scales[0]
            platformInterface.notifications.slider.scales.index_1 = config.slider.scales[1]
            platformInterface.notifications.slider.scales.index_2 = config.slider.scales[2]
            platformInterface.notifications.slider.states.index_0 = config.slider.states[0]
            platformInterface.notifications.slider.value = config.slider.value
            platformInterface.notifications.slider.values.index_0 = config.slider.values[0]
            platformInterface.notifications.slider.unit = config.slider.unit
            platformInterface.commands.slider.update(platformInterface.notifications.slider.value)
        }
        if (config.hasOwnProperty('infobox_integer')) {
            platformInterface.notifications.infobox_integer.caption = config.infobox_integer.caption
            platformInterface.notifications.infobox_integer.scales.index_0 = config.infobox_integer.scales[0]
            platformInterface.notifications.infobox_integer.scales.index_1 = config.infobox_integer.scales[1]
            platformInterface.notifications.infobox_integer.scales.index_2 = config.infobox_integer.scales[2]
            platformInterface.notifications.infobox_integer.states.index_0 = config.infobox_integer.states[0]
            platformInterface.notifications.infobox_integer.value = config.infobox_integer.value
            platformInterface.notifications.infobox_integer.values.index_0 = config.infobox_integer.values[0]
            platformInterface.notifications.infobox_integer.unit = config.infobox_integer.unit
            platformInterface.commands.infobox_integer.update(platformInterface.notifications.infobox_integer.value)
        }
        if (config.hasOwnProperty('infobox_double')) {
            platformInterface.notifications.infobox_double.caption = config.infobox_double.caption
            platformInterface.notifications.infobox_double.scales.index_0 = config.infobox_double.scales[0]
            platformInterface.notifications.infobox_double.scales.index_1 = config.infobox_double.scales[1]
            platformInterface.notifications.infobox_double.scales.index_2 = config.infobox_double.scales[2]
            platformInterface.notifications.infobox_double.states.index_0 = config.infobox_double.states[0]
            platformInterface.notifications.infobox_double.value = config.infobox_double.value
            platformInterface.notifications.infobox_double.values.index_0 = config.infobox_double.values[0]
            platformInterface.notifications.infobox_double.unit = config.infobox_double.unit
            platformInterface.commands.infobox_double.update(platformInterface.notifications.infobox_double.value)
        }
        if (config.hasOwnProperty('infobox_string')) {
            platformInterface.notifications.infobox_string.caption = config.infobox_string.caption
            platformInterface.notifications.infobox_string.scales.index_0 = config.infobox_string.scales[0]
            platformInterface.notifications.infobox_string.scales.index_1 = config.infobox_string.scales[1]
            platformInterface.notifications.infobox_string.scales.index_2 = config.infobox_string.scales[2]
            platformInterface.notifications.infobox_string.states.index_0 = config.infobox_string.states[0]
            platformInterface.notifications.infobox_string.value = config.infobox_string.value
            platformInterface.notifications.infobox_string.values.index_0 = config.infobox_string.values[0]
            platformInterface.notifications.infobox_string.unit = config.infobox_integer.unit
            platformInterface.commands.infobox_string.update(platformInterface.notifications.infobox_string.value)
        }
        if (config.hasOwnProperty('combobox')) {
            platformInterface.notifications.combobox.caption = config.combobox.caption
            platformInterface.notifications.combobox.scales.index_0 = config.combobox.scales[0]
            platformInterface.notifications.combobox.scales.index_1 = config.combobox.scales[1]
            platformInterface.notifications.combobox.scales.index_2 = config.combobox.scales[2]
            platformInterface.notifications.combobox.states.index_0 = config.combobox.states[0]
            platformInterface.notifications.combobox.values.index_0 = config.combobox.values[0]
            platformInterface.notifications.combobox.values.index_1 = config.combobox.values[1]
            platformInterface.notifications.combobox.values.index_2 = config.combobox.values[2]
            platformInterface.notifications.combobox.value = -1 // index must be reset if previous index was equal to current (is this a bug?)
            platformInterface.notifications.combobox.value = config.combobox.value // must be set after values are set
            platformInterface.notifications.combobox.unit = config.combobox.unit
            platformInterface.commands.combobox.update(platformInterface.notifications.combobox.value)
        }
    }

    // This function save settings to a .json configurations on disk, later to be recalled into platform interface by user
    function saveSettings(settingsName) {
        sgUserSettings.writeFile(`${settingsName}.json`,
            {
                "toggle": {
                    "caption": platformInterface.notifications.toggle.caption,
                    "scales": [
                        platformInterface.notifications.toggle.scales.index_0,
                        platformInterface.notifications.toggle.scales.index_1,
                        platformInterface.notifications.toggle.scales.index_2
                    ],
                    "states": [platformInterface.notifications.toggle.states.index_0],
                    "value": platformInterface.notifications.toggle.value,
                    "values": [
                        platformInterface.notifications.toggle.values.index_0,
                        platformInterface.notifications.toggle.values.index_1
                    ],
                    "unit": platformInterface.notifications.toggle.unit
                },
                "slider": {
                    "caption": platformInterface.notifications.slider.caption,
                    "scales": [
                        platformInterface.notifications.slider.scales.index_0,
                        platformInterface.notifications.slider.scales.index_1,
                        platformInterface.notifications.slider.scales.index_2
                    ],
                    "states": [platformInterface.notifications.slider.states.index_0],
                    "value": platformInterface.notifications.slider.value,
                    "values": platformInterface.notifications.slider.values,
                    "unit": platformInterface.notifications.slider.unit
                },
                "infobox_integer": {
                    "caption": platformInterface.notifications.infobox_integer.caption,
                    "scales": [
                        platformInterface.notifications.infobox_integer.scales.index_0,
                        platformInterface.notifications.infobox_integer.scales.index_1,
                        platformInterface.notifications.infobox_integer.scales.index_2
                    ],
                    "states": [platformInterface.notifications.infobox_integer.states.index_0],
                    "value": platformInterface.notifications.infobox_integer.value,
                    "values": platformInterface.notifications.infobox_integer.values,
                    "unit": platformInterface.notifications.infobox_integer.unit
                },
                "infobox_double": {
                    "caption": platformInterface.notifications.infobox_double.caption,
                    "scales": [
                        platformInterface.notifications.infobox_double.scales.index_0,
                        platformInterface.notifications.infobox_double.scales.index_1,
                        platformInterface.notifications.infobox_double.scales.index_2
                    ],
                    "states": [platformInterface.notifications.infobox_double.states.index_0],
                    "value": platformInterface.notifications.infobox_double.value,
                    "values": platformInterface.notifications.infobox_double.values,
                    "unit": platformInterface.notifications.infobox_double.unit
                },
                "infobox_string": {
                    "caption": platformInterface.notifications.infobox_string.caption,
                    "scales": [
                        platformInterface.notifications.infobox_string.scales.index_0,
                        platformInterface.notifications.infobox_string.scales.index_1,
                        platformInterface.notifications.infobox_string.scales.index_2
                    ],
                    "states": [platformInterface.notifications.infobox_string.states.index_0],
                    "value": platformInterface.notifications.infobox_string.value,
                    "values": platformInterface.notifications.infobox_string.values,
                    "unit": platformInterface.notifications.infobox_string.unit
                },
                "combobox": {
                    "caption": platformInterface.notifications.combobox.caption,
                    "scales": [
                        platformInterface.notifications.combobox.scales.index_0,
                        platformInterface.notifications.combobox.scales.index_1,
                        platformInterface.notifications.combobox.scales.index_2
                    ],
                    "states": [platformInterface.notifications.combobox.states.index_0],
                    "value": platformInterface.notifications.combobox.value,
                    "values": [
                        platformInterface.notifications.combobox.values.index_0,
                        platformInterface.notifications.combobox.values.index_1,
                        platformInterface.notifications.combobox.values.index_2
                    ],
                    "unit": platformInterface.notifications.combobox.unit
                }
            },
            cp_save_button.subdirName
        );
    }

    LayoutText { // start_36f96
        id: layoutText_36f96
        layoutInfo.uuid: "36f96"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 40

        text: "Save and Load Parameters"
        fontSizeMode: Text.Fit
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter
        color: "#000000"
    } // end_36f96

    LayoutDivider { // start_65192
        id: layoutDivider_65192
        layoutInfo.uuid: "65192"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 41
        thickness: 2
    } // end_65192

    LayoutSGInfoBox { // start_708bd
        id: cp_save_filename
        layoutInfo.uuid: "708bd"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 43

        placeholderText: "Enter parameter name"
        horizontalAlignment: Text.AlignLeft
        readOnly: false
    } // end_708bd

    LayoutButton { // start_912e7
        id: cp_save_button
        layoutInfo.uuid: "912e7"
        layoutInfo.columnsWide: 2
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 7
        layoutInfo.yRows: 43

        property string subdirName: "motor-template" // change this to your UI name
        text: "Save"

        onClicked: {
            const valid_filename_regex = new RegExp(/^[^\\\/\:\*\?\"\<\>\|\.]+$/); // Validate filename
            if (valid_filename_regex.test(cp_save_filename.text)) {
                // Valid filename if not empty
                if (cp_save_filename.text.length > 0) {
                    saveSettings(cp_save_filename.text)
                    cp_load_filename.updateList()
                    cp_save_filename.placeholderText = "Enter parameter name"
                } else {
                    cp_save_filename.placeholderText = "Invalid filename"
                }
            } else {
                // Invalid filename
                cp_save_filename.placeholderText = "Invalid filename"
            }
            cp_save_filename.text = ""
        }
    } // end_912e7

    LayoutSGComboBox { // start_93f08
        id: cp_load_filename
        layoutInfo.uuid: "93f08"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 46

        placeholderText: "Select Configuration"
        dividers: true
        textRole: "filename"
        model: ListModel {
            id: settingsModel
            // Additional files can be added here but you must ensure they exist in the .qrc file
            ListElement {
                filename: "Platform Interface Defaults"
                default_setting: true
                location: ":/settings/Platform Interface Defaults.json"
            }
            ListElement {
                filename: "Alternate Configuration"
                default_setting: true
                location: ":/settings/Alternate Configuration.json"
            }
            ListElement {
                filename: "All Disabled"
                default_setting: true
                location: ":/settings/All Disabled.json"
            }
            Component.onCompleted: {
                cp_load_filename.updateList()
            }
        }

        function getFileNameFromFile(file) {
            return file.slice(0, file.lastIndexOf('.'));
        }

        function updateList() {
            let filesInDir = sgUserSettings.listFilesInDirectory(cp_save_button.subdirName);
            for (let i = settingsModel.count - 1; i > -1; i--) {
                // remove all non-default settings
                if (settingsModel.get(i).default_setting === false) {
                    settingsModel.remove(i)
                }
            }

            for (let file of filesInDir) {
                settingsModel.append({
                    filename: getFileNameFromFile(file),
                    default_setting: false,
                    location: ""
                })
            }
        }
    } // end_93f08

    LayoutButton { // start_e96bf
        id: cp_delete_button
        layoutInfo.uuid: "e96bf"
        layoutInfo.columnsWide: 2
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 7
        layoutInfo.yRows: 47

        text: "Delete"

        onClicked: {
            if (cp_load_filename.currentIndex >= 0) {
                let current_file = cp_load_filename.model.get(cp_load_filename.currentIndex)
                if (current_file.default_setting === false) {
                    sgUserSettings.deleteFile(current_file.filename + '.json', cp_save_button.subdirName);
                    cp_load_filename.updateList()
                } else {
                    console.log("Can't delete default settings")
                }
            }
        }

    } // end_e96bf

    LayoutButton { // start_053a0
        id: cp_load_button
        layoutInfo.uuid: "053a0"
        layoutInfo.columnsWide: 2
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 7
        layoutInfo.yRows: 45

        text: "Load"

        onClicked: {
            if (cp_load_filename.currentIndex >= 0) {
                let current_file = cp_load_filename.model.get(cp_load_filename.currentIndex)
                let config
                if (current_file.default_setting) {
                    config = SGUtilsCpp.readTextFileContent(current_file.location)
                    config = JSON.parse(config)
                } else {
                    config = sgUserSettings.readFile(current_file.filename + ".json", cp_save_button.subdirName)
                }
                loadSettings(config)
            }
        }
    } // end_053a0

    LayoutRectangle { // start_cf371
        id: a_save_load_parameters_help
        layoutInfo.uuid: "cf371"
        layoutInfo.columnsWide: 8
        layoutInfo.rowsTall: 8
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 40
        opacity: 0
    } // end_cf371

} // end_uibase
