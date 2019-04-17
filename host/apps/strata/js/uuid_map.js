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
        CES HACK (class_id)
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
    "213": "",
    "214": "XDFN-LDO",
    "215": "5A-switcher",
    "216": "5A-switcher",
    "217": "XDFN-LDO",
    "218": "usb-hub",
    "219": "15A-switcher",
    "220": "15A-switcher",
    "222": "subGHz"
}
