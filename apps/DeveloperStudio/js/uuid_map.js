/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    "entice_rgb": "entice_rgb",
    "template": "template",
    "core-test-ui": "core-test-ui",

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
    "227": "eFuse",
    "228": "eFuse",
    "229": "eFuse",
    "230": "eFuse",
    "231": "ACF-PSU", // change this to actual AC - DC UUID which is 231
    "232": "subGHz2",
    "233": "sar-adc",
    "234": "Adj-LDO",
    "235": "Adj-LDO",
    "236": "Adj-LDO",
    "237": "Adj-LDO",
    "238": "ecoSWITCH",
    "239": "1A-LED",
    "240": "ldo-cp",
    "243": "Automotive-ADAS-Preregulator",
    "244": "motorController",
    "245": "bldcMotorControl",
    "246": "meshNetwork",
    "265": "zigbee",
    "9b8fb506-dd43-40a5-b762-2ec8b70cbb78": "template",

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
    "d0cc3eb2-f822-4955-afa4-b975957aed38": "Adj-LDO",
    "0570d932-6a3f-4a34-8442-cd9914518241": "current-sense",
    "76a518b4-37bc-4fee-ad5b-92c381dea0c2": "zigbee",
    "0d674fd9-3770-4ee7-ab0c-1f5f5de710fc": "usb-pd-pps",
    "bcd30065-a324-4a2c-8b55-05752c4eb76a": "FuelGauge-Monitor",
    "36c48ce4-3794-4ba7-a9f4-07fc6e45a8aa": "hello-strata-rsl10",
    "4a1c2e5f-d0b0-4970-8c93-70a9234d195c": "led-tail-light", // STR-NCV7685-AUTO-LED-GEVB
    "ecd43c02-3e7c-4d5e-9231-aabc149c8772": "led-tail-light",  // STR-NCV7684-AUTO-LED-GEVB
    "15411d3f-829f-4b65-b607-13e8dec840aa": "rsl10-dcdc",
    "1ae9e1e7-a268-4302-8c3a-280f0aa095a5": "rsl10-dcdc",
    "3ef8bbc6-92ff-4c98-b9ae-ca7e7c47d180": "rsl10-dcdc",
    "3ea08e05-0bcd-4a4a-86ec-79a1ca9750cd": "rsl10-dcdc",
    "abd65a0b-3229-44a4-a97c-38ea3c24f990": "rsl10-dcdc",
    "266f22e5-dc05-4819-b565-e5fb8035984e": "rsl10-dcdc",
    "b519cdcb-5068-4483-b88e-155813fae915": "rsl10-dcdc",
    "26ebc2ba-9bab-4bdd-97b6-09b5b8cbdf9e": "rsl10-dcdc",
    "cce0f32e-ee1e-44aa-81a3-0801a71048ce": "rsl10-dcdc",
    "2286e1e0-4035-46b9-b197-4d729653c101": "rsl10-dcdc",
    "4aad7090-eac3-470e-a304-00988c8c006d": "rsl10-dcdc",
    "7bdcea96-0fb8-41de-9822-dec20ae1032a": "level-translators",
    "fda98159-37f0-4e07-9ffe-28f46f80f7b5": "100V-ncp1034",
    "8a757b79-ba44-4830-864b-2bb965552209": "pixel",
    "a34fc0ce-a3fc-4f6b-8c0c-b17aaffff5ff": "ncs32100",
    "057ec75e-e48f-42db-bea9-3d191ed8a736": "rsl10-pmbus",
    "d4937f24-219a-4648-a711-2f6e902b6f1c": "rsl10-pmbus",
    "a4e20d30-af03-43cf-98cf-b10cc5c7aa28": "MDK-UCB",
    "d64c7dea-4509-45c6-8f99-02bf6e091366": "MDK-UCB",
    "334aeac5-129f-4f31-83f1-461a5cfd7377": "MDK-UCB",
    "a715b4d6-b9a3-4fdf-a1da-bcf629146232": "SiC-SSDC-INV-UCB",
    "b3743305-a33c-4dda-8120-b28bb7e4ba50": "dms-ir-led",
    "abc1cf67-bfb4-4e08-8c67-e6a78f9b9adb": "mv-mdk",
    "c7069a8a-0dd9-40cf-ac89-29aafabb02a2": "mv-mdk",
    "b1133641-5b46-4d11-9b96-9126b9d2a109": "mv-mdk",
    "1917934f-3b79-4e8b-b37a-b1bd92d2afd5": "mv-mdk",
    "d5029d50-9f39-4e44-8c35-589686b511cb": "lighting-kit-demo",
    "12ef019d-4c18-4898-984e-6dc301d4be56": "ncv7685-rear",
    "aade6dda-6c67-4c72-b80d-18b086fe3abf": "NCS32200",
}
