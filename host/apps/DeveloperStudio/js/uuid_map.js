.pragma library

// Map out class_id->platform name
// Lookup table
// platform_id -> local qml directory holding interface
// to enable a new model of board UI to be shown, this list has to be edited
// the other half of the map will be the name of the directory that will be used to show the initial screen (e.g. usb-pd/Control.qml)

var uuid_map = {
    /*****
        Original (uuid)
    *****/
    "P2.2017.1.1.0": "usb-pd",             //original version
    "P2.2018.1.1.0": "bubu",
    "P2.2018.0.0.0": "usb-pd-multiport",       //uninitialized board
    "SEC.2017.004.2.0": "motor-vortex",
    "SEC.2018.004.0.1": "usb-pd",
    "SEC.2018.004.1.0": "usb-pd",
    "SEC.2018.004.1.1": "usb-pd",
    "SEC.2018.004.1.2": "usb-pd",
    "SEC.2017.038.0.0": "usb-pd-multiport",
    "SEC.2017.038.0.1": "usb-pd-multiport",
    "SEC.2018.018.0.0": "logic-gate", // Alpha Board
    "SEC.2018.018.1.0": "logic-gate", // Beta Board
    "SEC.2018.001.0.0": "usb-hub",
    "TEST.2018.002.0.0": "motor-vortex",
    "entice_rgb" : "entice_rgb",
    "template": "template",


    /*****
        CES HACK or temporary Class ID for development purposes(class_id)
    *****/
    "101": "logic-gate",
    "201": "logic-gate",
    "202": "usb-pd",
    "203": "usb-pd-multiport",
    "204": "motor-vortex",
    "206": "XDFN-LDO",
    "207": "15A-switcher",
    "208": "5A-switcher",
    "209": "led",
    "210": "XDFN-LDO",
    "211": "XDFN-LDO",
    "212": "XDFN-LDO",
    "213": "sensor",
    "214": "XDFN-LDO",
    "215": "5A-switcher",
    "216": "5A-switcher-NCV6357",
    "217": "XDFN-LDO",
    "218": "usb-hub",
    "219": "15A-switcher",
    "220": "15A-switcher",
    "221": "usb-pd-pps",
    "222": "subGHz",
    "225": "smart-speaker",
    "226": "hello-strata",
    "227" : "eFuse",
    "228" : "eFuse",
    "229" : "eFuse",
    "225": "smart-speaker",
    "226": "hello-strata",
    "230" : "eFuse",
    "231": "ACF-PSU", // change this to actual AC - DC UUID which is 231
    "232": "subGHz2",
    "233": "sar-adc",
    "234" : "Adj-LDO",
    "235" : "Adj-LDO",
    "236" : "Adj-LDO",
    "237" : "Adj-LDO",
    "238": "ecoSWITCH",
    "239": "1A-LED",
    "240": "ldo-cp",
    "241": "fan6500xx",
    "242": "fan6500xx",
    "243": "Automotive-ADAS-Preregulator",
    "244": "motorController",
    "245": "bldcMotorControl",
    "246": "meshNetwork",
    "265": "zigbee",

    /*****
        Real UUID generated from interaction with Deployment Portal (class_id)
    *****/
    "72ddcc10-2d18-4316-8170-5223162e54cf": "sensor",
    "87054646-955d-42ed-aa82-8927b6a70286": "motorController",
    "b8a53467-4155-4104-905e-8d23bb5664a3": "Adj-LDO",
    "8da4158e-caa7-469d-8e4c-949d7a7e9858": "Adj-LDO",
    "043683ef-537b-49e6-a090-30e314a73265": "fan6500xx", //4B
    "101d15b0-3aa9-40b5-a1ae-b0e0b87f4f5b": "fan6500xx", //4C
    "f81d23a7-3c93-40c6-ac5f-e836e936728b": "fan6500xx", //5A
    "a3359627-3938-4a84-9a9c-fb57ff22deed": "fan6500xx", //8B
}
