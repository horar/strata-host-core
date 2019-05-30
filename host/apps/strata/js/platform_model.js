.pragma library
.import "platform_selection.js" as PlatformSelection
.import "uuid_map.js" as UuidMap

.import Strata.Logger 1.0 as LoggerModule

///////////
//
//  This is a hardcoded list of platforms that will function until HCS can serve this information to UI from PRT and Deployment Portal
//
///////////

//TODO: when CoreInterface makes this obsolete, uncomment populatePlatforms() calls so the CoreInterface list is used (main.qml, sgstatusbar.qml)

var platforms = { "list":
        [
        {
            "on_part_number": "STR-LOGIC-GATES-EVK",
            "verbose_name": "Multi-function Logic Gate with GUI Control",
            "description": "Two individual 7-in-1 logic gates with simple GUI input and output state control/indication.",
            "image": "201.png",
            "application_icons": [
                "computing",
                "consumer"
            ],
            "product_icons": [
                "digital"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "201",
            "connection": "view"
        },

        {
            "on_part_number": "STR-USBC-2PORT-100W-EVK",
            "verbose_name": "USB Auto 2-Port 100W Source",
            "description": "The 2-Port USB-PD Source showcases ON Semiconductor's broad portfolio of USB-PD power solutions.",
            "image": "202.png",
            "application_icons": [
                "automotive",
                "consumer"
            ],
            "product_icons": [
                "connectivity",
                "dc",
                "discrete"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "202",
            "connection": "view"
        },

        {
            "on_part_number": "STR-USBC-4PORT-200W-EVK",
            "verbose_name": "USB AC-DC 4-Port 200W Source",
            "description": "The 4-Port USB-PD Source showcases ON Semiconductor's broad portfolio of USB-PD power solutions, including the FUSB307 PD Port Controller, the FUSB252 HV Protection Switch, and the NCP81231 buck controller.",
            "image": "203.png",
            "application_icons": [
                "computing",
                "consumer",
                "powersupply"
            ],
            "product_icons": [
                "ac",
                "analog",
                "dc",
                "discrete"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "203",
            "connection": "view"
        },

        {
            "on_part_number": "STR-4LED-SOL-EVAL-EVK",
            "verbose_name": "Multi-solution LED board with GUI Control",
            "description": "Four solution LED Evaluation Board providing high-power buck, boost, and RGB solutions",
            "image": "209.png",
            "application_icons": [
                "automotive",
                "consumer",
                "industrial",
                "ledlighting",
                "whitegoods"
            ],
            "product_icons": [
                "analog",
                "dc",
                "digital",
                "discrete",
                "led"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "209",
            "connection": "view"
        },

        {
            "on_part_number": "STR-NCP110-EVK",
            "verbose_name": "NCP110 - 200mA LDO",
            "description": "The STR-NCP110-EVK provides an evaluation kit for the NCP110 series of 200 mA low noise and high PSRR XDFN4 package LDOs.",
            "image": "210.png",
            "application_icons": [
                "computing",
                "consumer",
                "powersupply",
                "wirelessiot"
            ],
            "product_icons": [
                "analog",
                "dc",
                "discrete"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "210",
            "connection": "view"
        },

        {
            "on_part_number": "STR-NCP115-EVK",
            "verbose_name": "NCP115 - 300mA LDO",
            "description": "The STR-NCP115-EVK provides an evaluation kit for the NCP115 series of 300 mA low quiescent current XDFN4 package LDOs.",
            "image": "210.png",
            "application_icons": [
                "computing",
                "consumer",
                "powersupply",
                "wirelessiot"
            ],
            "product_icons": [
                "analog",
                "dc",
                "discrete"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "211",
            "connection": "view"
        },

        {
            "on_part_number": "STR-NCV8163-NCP163-EVK",
            "verbose_name": "NCV8163/NCP163 - 250mA LDO",
            "description": "The STR-NCV8163-NCP163-EVK provides an evaluation kit for the NCV8163 and NCP163 series of 250 mA ultra-low noise and high PSRR XDFN4 package LDOs.",
            "image": "210.png",
            "application_icons": [
                "automotive",
                "computing",
                "consumer",
                "industrial",
                "powersupply"
            ],
            "product_icons": [
                "analog",
                "dc",
                "discrete"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "206",
            "connection": "view"
        },

        {
            "on_part_number": "STR-NCV8170-NCP170-EVK",
            "verbose_name": "NCV8170/NCP170 - 150mA LDO",
            "description": "The STR-NCV8170-NCP170-EVK provides an evaluation kit for the NCV8170 and NCP170 series of 150 mA CMOS ultra-low quiescent current XDFN4 package LDOs.",
            "image": "210.png",
            "application_icons": [
                "automotive",
                "computing",
                "consumer",
                "industrial",
                "powersupply"
            ],
            "product_icons": [
                "analog",
                "dc",
                "discrete"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "212",
            "connection": "view"
        },

        {
            "on_part_number": "STR-NCP171-EVK",
            "verbose_name": "NCP171 - 80mA Dual Power Mode LDO",
            "description": "The STR-NCP171-EVK provides an evaluation kit for the NCP171 series of 80 mA dual mode XDFN4 package LDOs.",
            "image": "210.png",
            "application_icons": [
                "computing",
                "consumer",
                "powersupply"
            ],
            "product_icons": [
                "analog",
                "dc",
                "discrete"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "217",
            "connection": "view"
        },



        {
            "on_part_number": "STR-NCV6356-EVK",
            "verbose_name": "NCV6356 5A AOT Step Down Converter",
            "description": "The STR-NCV6356-EVK provides an evaluation kit for the NCV6356 configurable 5.0 A Adaptive-On-Time (AOT) step down converter a with I2C programmable output voltage.",
            "image": "208.png",
            "application_icons": [
                "automotive",
                "computing",
                "consumer",
                "industrial",
                "powersupply"
            ],
            "product_icons": [
                "analog",
                "dc",
                "discrete"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "208",
            "connection": "view"
        },

        {
            "on_part_number": "STR-NCV6357-EVK",
            "verbose_name": "NCV6357 5A AOT Step Down Converter",
            "description": "The STR-NCV6357-EVK provides an evaluation kit for the NCV6357 configurable 5.0 A Adaptive-On-Time (AOT) step down converter a with I2C programmable output voltage.",
            "image": "208.png",
            "application_icons": [
                "automotive",
                "computing",
                "consumer",
                "industrial",
                "powersupply"
            ],
            "product_icons": [
                "analog",
                "dc",
                "discrete"
            ],
            "available":{
                "documents": false,
                "control": false
            },
            "class_id": "216",
            "connection": "view"
        },

        {
            "on_part_number": "STR-NCP3231-EVK",
            "verbose_name": "18V INPUT, 25A SWITCHER",
            "description": "Voltage mode, synchronous buck converter, which operates from 4.5V to 18 Vin and generates outputs as lows as 0.6V at 25A of continuous current",
            "image": "207.png",
            "application_icons": [
                "computing",
                "industrial",
                "networkingtelecom",
                "powersupply"
            ],
            "product_icons": [
                "dc",
                "analog"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "220",
            "connection": "view"
        },

        {
            "on_part_number": "STR-NCP3232N-EVK",
            "verbose_name": "23V INPUT, 15A SWITCHER",
            "description": "Voltage mode, synchronous buck converter, which operates from 4.5V to 23 Vin and generates outputs as lows as 0.6V at 15A of continuous current",
            "image": "207.png",
            "application_icons": [
                "computing",
                "industrial",
                "networkingtelecom",
                "powersupply"
            ],
            "product_icons": [
                "dc",
                "analog"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "219",
            "connection": "view"
        },

        {
            "on_part_number": "STR-NCP3235-EVK",
            "verbose_name": "23V INPUT, 15A SWITCHER",
            "description": "Voltage mode, synchronous buck converter, which operates from 4.5V to 23 Vin and generates outputs as lows as 0.6V at 15A of continuous current",
            "image": "207.png",
            "application_icons": [
                "computing",
                "industrial",
                "networkingtelecom",
                "powersupply"
            ],
            "product_icons": [
                "dc",
                "analog"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "207",
            "connection": "view"
        },



        {
            "on_part_number": "STR-SENSORS-EVK",
            "verbose_name": "Touch, Proximity, Light and Temperature Sensors",
            "description": "Evaluate the portfolio of various sensors used for touch or proximity detection, ambient light, and thermal detection.",
            "image": "notFound.png",
            "application_icons": [
                "consumer",
                "industrial",
                "whitegoods",
                "wirelessiot"
            ],
            "product_icons": [
                "connectivity",
                "digital",
                "sensor"
            ],
            "available":{
                "documents": false,
                "control": false
            },
            "class_id": "213",
            "connection": "view"
        },

        //        {   // Platform is not publicly available
        //            "on_part_number": "STR-VORTEX-FOUNTAIN-DEMO",
        //            "verbose_name": "Vortex Fountain Motor Platform Demo",
        //            "description": "This demo uses sensor-less 3 phase BLDC motor controller LV8907 to drive the pump which creates a water voretx and is lit with color mixing LEDs driven by CAT9532.",
        //            "image": "204.png",
        //            "application_icons": [
        //                "consumer",
        //                "industrial",
        //                "ledlighting",
        //                "motorcontrol",
        //                "powersupply"
        //            ],
        //            "product_icons": [
        //                "dc",
        //                "digital",
        //                "discrete",
        //                "led"
        //            ],
        //            "available":{
        //                "documents": false,
        //                "control": false
        //                       },
        //            "class_id": "204",
        //            "connection": "view"
        //        },

        //        {
        //            "on_part_number": "STR-Strata",
        //            "verbose_name": "Example Platform",
        //            "description": "This example platform is just a template that keeps a record of all the available icons and also show a 'coming soon' platform",
        //            "image": "notFound.png",
        //            "application_icons": [
        //                "automotive",
        //                "computing",
        //                "consumer",
        //                "industrial",
        //                "ledlighting",
        //                "medical",
        //                "militaryaerospace",
        //                "motorcontrol",
        //                "networkingtelecom",
        //                "powersupply",
        //                "whitegoods",
        //                "wirelessiot"
        //            ],
        //            "product_icons": [
        //                "ac",
        //                "analog",
        //                "audio",
        //                "connectivity",
        //                "dc",
        //                "digital",
        //                "discrete",
        //                "esd",
        //                "imagesensors",
        //                "infrared",
        //                "led",
        //                "mcu",
        //                "memory",
        //                "optoisolator",
        //                "pm",
        //                "sensor",
        //                "video"
        //            ],
        //            "available":{
        //                "documents": false,
        //                "control": false
        //            },
        //            "class_id": "209",
        //            "connection": "view"
        //        }
    ]
}


var cachedShortCircuitDocuments
var cachedShortCircuitControl

function shortCircuit (platform_list_json) {
    try {
        var platform_list = JSON.parse(platform_list_json)
        var connected = false
        for (var i = 0; i < platform_list.list.length; i ++){
            var class_idPattern = new RegExp('^[0-9]{3,10}$');
            var class_id = String(platform_list.list[i].class_id);
            if (class_idPattern.test(class_id) && class_id !== "undefined" && UuidMap.uuid_map.hasOwnProperty(class_id) && platform_list.list[i].connection === "connected") {
                // for every connected listing in plat_list (should only be 1), and check against platformListModel for match, and update the model entry to connected
                for (var j = 0; j < PlatformSelection.platformListModel.count; j ++) {
                    if (platform_list.list[i].class_id === PlatformSelection.platformListModel.get(j).class_id ) {

                        PlatformSelection.platformListModel.currentIndex = j
                        PlatformSelection.platformListModel.get(j).connection = "connected"

                        // cache old hard-coded model values
                        cachedShortCircuitDocuments = PlatformSelection.platformListModel.get(j).available.documents
                        cachedShortCircuitControl = PlatformSelection.platformListModel.get(j).available.control
                        PlatformSelection.platformListModel.get(j).available = {
                            "documents": true,
                            "control": true
                        }
                        PlatformSelection.platformListModel.selectedClass_id = platform_list.list[i].class_id
                        PlatformSelection.platformListModel.selectedName = UuidMap.uuid_map[class_id]
                        PlatformSelection.platformListModel.selectedConnection = platform_list.list[i].connection
                        connected = true
                    }
                }

                if (!connected) {
                    // In scenario where hardcoded platform doesn't exist (ie motor vortex is unlisted on purpose), create entry for it
                    var platform_info = {
                        "verbose_name" : "Unlisted Platform: " + platform_list.list[i].name,
                        "name" : UuidMap.uuid_map[class_id],
                        "connection" : "connected",
                        "class_id" : platform_list.list[i].class_id,
                        "on_part_number": "",
                        "description": "Unlisted platform was connected, with class_id: " + platform_list.list[i].class_id,
                        "image": "notFound.png",
                        "available": { "control": true, "documents": true }
                    }

                    cachedShortCircuitDocuments = false
                    cachedShortCircuitControl = false

                    PlatformSelection.platformListModel.selectedClass_id = platform_info.class_id
                    PlatformSelection.platformListModel.selectedName = platform_info.name
                    PlatformSelection.platformListModel.selectedConnection = platform_info.connection

                    PlatformSelection.platformListModel.append(platform_info)
                    PlatformSelection.platformListModel.currentIndex = (PlatformSelection.platformListModel.count - 1)

                    connected = true
                }

                break;
            }
        }
        // if no connected platforms were detected, find previously connected plaform and reset its statuses
        if (!connected) {
            for (var k = 0; k < PlatformSelection.platformListModel.count; k ++){
                if (PlatformSelection.platformListModel.get(k).connection === "connected") {
                    // restore cached values
                    PlatformSelection.platformListModel.get(k).available = {
                        "documents": cachedShortCircuitDocuments,
                        "control": cachedShortCircuitControl
                    }
                    PlatformSelection.platformListModel.get(k).connection = "view"
                    break;
                }
            }
            PlatformSelection.deselectPlatform()
        } else {
            // Move connected plat listing to top of list
            PlatformSelection.platformListModel.move(PlatformSelection.platformListModel.currentIndex, 0, 1)
            PlatformSelection.platformListModel.currentIndex = 0

            PlatformSelection.sendSelection()
        }
    } catch(err) {
        console.log(LoggerModule.Logger.devStudioPlatformModelCategory, "SHORTCIRCUIT error:", err.toString())
        PlatformSelection.platformListModel.clear()
        PlatformSelection.platformListModel.append({ "verbose_name" : "Error! No platforms available" })
    }
}
