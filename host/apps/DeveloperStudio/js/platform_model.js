.pragma library

///////////
//
//  This is a hardcoded list of platforms that will function until HCS can serve this information to UI from Cloud/Deployment Portal
//  [TODO] - if this is ever removed, also remove the platform images from platform-selector/images.
//
///////////

var platforms = {
    "path_prefix":"partial-views/platform-selector/images/platform-images/",
    "list":
        [
        {
            "opn": "STR-LOGIC-GATES-EVK",
            "verbose_name": "Multi-function Logic Gate with GUI Control",
            "description": "Two individual 7-in-1 logic gates with simple GUI input and output state control/indication.",
            "image": {
               "file": "201.png"
            },
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
            "opn": "STR-USBC-2PORT-100W-EVK",
            "verbose_name": "USB Auto 2-Port 100W Source",
            "description": "The 2-Port USB-PD Source showcases ON Semiconductor's broad portfolio of USB-PD power solutions.",
            "image": {
               "file": "202.png"
            },
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
            "opn": "STR-USBC-4PORT-200W-EVK",
            "verbose_name": "USB AC-DC 4-Port 200W Source",
            "description": "The 4-Port USB-PD Source showcases ON Semiconductor's broad portfolio of USB-PD power solutions, including the FUSB307 PD Port Controller, the FUSB252 HV Protection Switch, and the NCP81231 buck controller.",
            "image": {
               "file": "203.png"
            },
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
            "opn": "STR-4LED-SOL-EVAL-EVK",
            "verbose_name": "Multi-solution LED board with GUI Control",
            "description": "Four solution LED Evaluation Board providing high-power buck, boost, and RGB solutions",
            "image": {
               "file": "209.png"
            },
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
            "opn": "STR-NCP110-EVK",
            "verbose_name": "NCP110 - 200mA LDO",
            "description": "The STR-NCP110-EVK provides an evaluation kit for the NCP110 series of 200 mA low noise and high PSRR XDFN4 package LDOs.",
            "image": {
               "file": "210.png"
            },
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
            "opn": "STR-NCP115-EVK",
            "verbose_name": "NCP115 - 300mA LDO",
            "description": "The STR-NCP115-EVK provides an evaluation kit for the NCP115 series of 300 mA low quiescent current XDFN4 package LDOs.",
            "image": {
               "file": "210.png"
            },
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
            "opn": "STR-NCV8163-NCP163-EVK",
            "verbose_name": "NCV8163/NCP163 - 250mA LDO",
            "description": "The STR-NCV8163-NCP163-EVK provides an evaluation kit for the NCV8163 and NCP163 series of 250 mA ultra-low noise and high PSRR XDFN4 package LDOs.",
            "image": {
               "file": "210.png"
            },
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
            "opn": "STR-NCV8170-NCP170-EVK",
            "verbose_name": "NCV8170/NCP170 - 150mA LDO",
            "description": "The STR-NCV8170-NCP170-EVK provides an evaluation kit for the NCV8170 and NCP170 series of 150 mA CMOS ultra-low quiescent current XDFN4 package LDOs.",
            "image": {
               "file": "210.png"
            },
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
            "opn": "STR-NCP171-EVK",
            "verbose_name": "NCP171 - 80mA Dual Power Mode LDO",
            "description": "The STR-NCP171-EVK provides an evaluation kit for the NCP171 series of 80 mA dual mode XDFN4 package LDOs.",
            "image": {
               "file": "210.png"
            },
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
            "opn": "STR-NCV6356-EVK",
            "verbose_name": "NCV6356 5A AOT Step Down Converter",
            "description": "The STR-NCV6356-EVK provides an evaluation kit for the NCV6356 configurable 5.0 A Adaptive-On-Time (AOT) step down converter a with I2C programmable output voltage.",
            "image": {
               "file": "208.png"
            },
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
            "opn": "STR-NCV6357-GEVB",
            "verbose_name": "NCV6357 5A AOT Step Down Converter",
            "description": "The Strata Enabled NCV6357 EVB provides an easy to use evaluation board within the Strata Development Environment for the NCV6357 configurable 5A step down converter.",
            "image": {
                "file": "216.png"
            },
            "application_icons": [
                "automotive",
                "computing",
                "consumer",
                "industrial",
                "powersupply"
            ],
            "product_icons": [
                "dc",
                "discrete"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "216",
            "connection": "view"
        },

        {
            "opn": "STR-NCP3231-EVK",
            "verbose_name": "18V INPUT, 25A SWITCHER",
            "description": "Voltage mode, synchronous buck converter, which operates from 4.5V to 18 Vin and generates outputs as lows as 0.6V at 25A of continuous current",
            "image": {
               "file": "207.png"
            },
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
            "opn": "STR-NCP3232N-EVK",
            "verbose_name": "23V INPUT, 15A SWITCHER",
            "description": "Voltage mode, synchronous buck converter, which operates from 4.5V to 23 Vin and generates outputs as lows as 0.6V at 15A of continuous current",
            "image": {
               "file": "207.png"
            },
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
            "opn": "STR-NCP3235-EVK",
            "verbose_name": "23V INPUT, 15A SWITCHER",
            "description": "Voltage mode, synchronous buck converter, which operates from 4.5V to 23 Vin and generates outputs as lows as 0.6V at 15A of continuous current",
            "image": {
               "file": "207.png"
            },
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

        // {
        //     "opn": "STR-SENSORS-EVK",
        //     "verbose_name": "Touch, Proximity, Light and Temperature Sensors",
        //     "description": "Evaluate the portfolio of various sensors used for touch or proximity detection, ambient light, and thermal detection.",
        //     "image": {
        //         "file": "notFound.png"
        //     },
        //     "application_icons": [
        //         "consumer",
        //         "industrial",
        //         "whitegoods",
        //         "wirelessiot"
        //     ],
        //     "product_icons": [
        //         "connectivity",
        //         "digital",
        //         "sensor"
        //     ],
        //     "available":{
        //         "documents": false,
        //         "control": false
        //     },
        //     "class_id": "213",
        //     "connection": "view"
        // },

        {
            "opn": "STR-NIS5020-GEVB",
            "verbose_name": "NIS5020 12V eFuse",
            "description": "The STR-NIS5020-GEVB provides an evaluation board for the NIS5020 12V eFuse within the Strata Development Environment.",
            "image": {
                "file": "227.png"
            },
            "application_icons": [
                "computing",
                "consumer",
                "powersupply"
            ],
            "product_icons": [
                "dc",
                "pm"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "227",
            "connection": "view"
        },

        {
            "opn": "STR-NIS5132-GEVB",
            "verbose_name": "NIS5132 12V eFuse",
            "description": "The STR-NIS5132-GEVB provides an evaluation board for the NIS5132 12V eFuse within the Strata Development Environment.",
            "image": {
                "file": "227.png"
            },
            "application_icons": [
                "computing",
                "consumer",
                "powersupply"
            ],
            "product_icons": [
                "dc",
                "pm"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "229",
            "connection": "view"
        },

        {
            "opn": "STR-NIS5232-GEVB",
            "verbose_name": "NIS5232 12V eFuse",
            "description": "The STR-NIS5232-GEVB provides an evaluation board for the NIS5232 12V eFuse within the Strata Development Environment.",
            "image": {
                "file": "227.png"
            },
            "application_icons": [
                "computing",
                "consumer",
                "powersupply"
            ],
            "product_icons": [
                "dc",
                "pm"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "230",
            "connection": "view"
        },

        {
            "opn": "STR-NIS5820-GEVB",
            "verbose_name": "NIS5820 12V eFuse",
            "description": "The STR-NIS5820-GEVB provides an evaluation board for the NIS5820 12V eFuse within the Strata Development Environment.",
            "image": {
                "file": "227.png"
            },
            "application_icons": [
                "computing",
                "consumer",
                "powersupply"
            ],
            "product_icons": [
                "dc",
                "pm"
            ],
            "available":{
                "documents": true,
                "control": true
            },
            "class_id": "228",
            "connection": "view"
        }

        //        {
        //            "opn": "STR-Strata",
        //            "verbose_name": "Example Platform",
        //            "description": "This example platform is just a template that keeps a record of all the available icons and also show a 'coming soon' platform",
        //            ""image": {
        //                "file": "notFound.png"
        //             },
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
