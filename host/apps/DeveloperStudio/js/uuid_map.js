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
    "243": "Automotive-ADAS-Preregulator",
    "244": "motorController",
    "245": "bldcMotorControl",
    "246": "meshNetwork",
    "265": "zigbee",
    "15411d3f-829f-4b65-b607-13e8dec840aa": "rsl10-dcdc",
    "1ae9e1e7-a268-4302-8c3a-280f0aa095a5": "rsl10-dcdc",
    "3ef8bbc6-92ff-4c98-b9ae-ca7e7c47d180": "rsl10-dcdc",
    "3ea08e05-0bcd-4a4a-86ec-79a1ca9750cd": "rsl10-dcdc",
    "abd65a0b-3229-44a4-a97c-38ea3c24f990": "rsl10-dcdc",
    "266f22e5-dc05-4819-b565-e5fb8035984e": "rsl10-dcdc",
    "d4937f24-219a-4648-a711-2f6e902b6f1c": "rsl10-dcdc",
    "b519cdcb-5068-4483-b88e-155813fae915": "rsl10-dcdc",
    "26ebc2ba-9bab-4bdd-97b6-09b5b8cbdf9e": "rsl10-dcdc",
    "cce0f32e-ee1e-44aa-81a3-0801a71048ce": "rsl10-dcdc",
    "2286e1e0-4035-46b9-b197-4d729653c101": "rsl10-dcdc",
    "4aad7090-eac3-470e-a304-00988c8c006d": "rsl10-dcdc",
    "057ec75e-e48f-42db-bea9-3d191ed8a736": "rsl10-dcdc",

    /*****
        Real UUID generated from interaction with Deployment Portal (class_id)
    *****/
    "72ddcc10-2d18-4316-8170-5223162e54cf": "sensor",
    "87054646-955d-42ed-aa82-8927b6a70286": "motorController",
    "b8a53467-4155-4104-905e-8d23bb5664a3": "Adj-LDO",
    "8da4158e-caa7-469d-8e4c-949d7a7e9858": "Adj-LDO",
    "d0cc3eb2-f822-4955-afa4-b975957aed38": "Adj-LDO",
    "0570d932-6a3f-4a34-8442-cd9914518241": "current-sense",
    "76a518b4-37bc-4fee-ad5b-92c381dea0c2": "zigbee",
    "0d674fd9-3770-4ee7-ab0c-1f5f5de710fc": "usb-pd-pps",
    "bcd30065-a324-4a2c-8b55-05752c4eb76a": "FuelGauge-Monitor"

}
