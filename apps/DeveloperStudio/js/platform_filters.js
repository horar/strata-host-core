/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
.pragma library
.import tech.strata.logger 1.0 as LoggerModule

var filterModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {}",Qt.application,"filterModel")

var rawData = [
            //segments
            {
                "filterId": "segment-automotive",
                "name": "Automotive",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-automotive.svg",
            },
            {
                "filterId": "segment-industrial-cloud-power",
                "name": "Industrial & Cloud Power",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-industrial-cloud-power.svg",
            },
            {
                "filterId": "segment-iot",
                "name": "Internet of Things (IoT)",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-iot.svg",
            },

            //categories
            {
                "filterId": "category-amplifier-comparator",
                "name": "Amplifiers & Comparators",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/amplifiers_and_comparators.svg",

            },
            {
                "filterId": "category-audio-video",
                "name": "Audio/Video ASSP",
            },
            {
                "filterId": "category-connectivity",
                "name": "Connectivity",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/connectivity.svg",
            },
            {
                "filterId": "category-sensor",
                "name": "Sensors",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/sensors.svg",
            },
            {
                "filterId": "category-iso-protection",
                "name": "Isolation & Protection Devices",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/isolation_and_protection.svg",
            },
            {
                "filterId": "category-power-management",
                "name": "Power Management",
            },
            {
                "filterId": "category-power-module",
                "name": "Power Modules",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/battery.svg",
            },
            {
                "filterId": "category-interface",
                "name": "Interfaces",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/interfaces.svg",
            },
            {
                "filterId": "category-clock-timing",
                "name": "Clock & Timing",
            },
            {
                "filterId": "category-discrete-driver",
                "name": "Discretes & Drivers",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/discretes_and_drivers.svg",
            },
            {
                "filterId": "category-memory",
                "name": "Memory",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/memory.svg",
            },
            {
                "filterId": "category-optoelectronic",
                "name": "Optoelectronics",
            },
            {
                "filterId": "category-microcontroller",
                "name": "Microcontrollers",
            },
            {
                "filterId": "category-standard-logic",
                "name": "Standard Logic",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/logic_gates.svg",
            },
            //subcategories
            {
                "filterId": "subcategory-ampcomp-audio-power",
                "name": "Audio Power Amplifiers",
                "parentCategory": "category-amplifier-comparator"
            },
            {
                "filterId": "subcategory-ampcomp-comparator",
                "name": "Comparators",
                "parentCategory": "category-amplifier-comparator"
            },
            {
                "filterId": "subcategory-ampcomp-current-sense",
                "name": "Current Sense Amplifiers",
                "parentCategory": "category-amplifier-comparator"
            },
            {
                "filterId": "subcategory-ampcomp-op-amp",
                "name": "Operational Amplifiers (Op Amps)",
                "parentCategory": "category-amplifier-comparator"
            },
            {
                "filterId": "subcategory-ampcomp-video-amp",
                "name": "Video Amplifiers",
                "parentCategory": "category-amplifier-comparator"
            },
            {
                "filterId": "subcategory-av-audio-assp",
                "name": "Audio ASSP",
                "parentCategory": "category-audio-video"
            },
            {
                "filterId": "subcategory-av-audio-dsp",
                "name": "Audio DSP Systems",
                "parentCategory": "category-audio-video"
            },
            {
                "filterId": "subcategory-av-audiology-dsp",
                "name": "Audiology DSP Systems",
                "parentCategory": "category-audio-video"
            },
            {
                "filterId": "subcategory-av-lcd",
                "name": "LCD Drivers",
                "parentCategory": "category-audio-video"
            },
            {
                "filterId": "subcategory-av-video-conditioning",
                "name": "Video Conditioning",
                "parentCategory": "category-audio-video"
            },
            {
                "filterId": "subcategory-conn-trans-modem",
                "name": "Wired Transceivers & Modems",
                "parentCategory": "category-connectivity"
            },
            {
                "filterId": "subcategory-conn-microwave",
                "name": "Monolithic Microwave Integrated Circuits (MMIC)",
                "parentCategory": "category-connectivity"
            },
            {
                "filterId": "subcategory-conn-rf",
                "name": "Wireless RF Transceivers",
                "parentCategory": "category-connectivity"
            },
            {
                "filterId": "subcategory-conn-tunable",
                "name": "Tunable Components",
                "parentCategory": "category-connectivity"
            },
            {
                "filterId": "subcategory-conn-wifi",
                "name": "WiFi Solutions",
                "parentCategory": "category-connectivity"
            },
            {
                "filterId": "subcategory-sensor-light",
                "name": "Ambient Light Sensors",
                "parentCategory": "category-sensor"
            },
            {
                "filterId": "subcategory-sensor-light",
                "name": "Image Sensors & Processors",
                "parentCategory": "category-sensor"
            },
            {
                "filterId": "subcategory-sensor-thermal",
                "name": "Thermal Management",
                "parentCategory": "category-sensor"
            },
            {
                "filterId": "subcategory-sensor-touch",
                "name": "Touch Sensors",
                "parentCategory": "category-sensor"
            },
            {
                "filterId": "subcategory-sensor-battery",
                "name": "Battery-Free Wireless Sensor Tags",
                "parentCategory": "category-sensor"
            },
            {
                "filterId": "subcategory-sensor-sipm",
                "name": "Silicon Photomultipliers (SiPM)",
                "parentCategory": "category-sensor"
            },
            {
                "filterId": "subcategory-isopro-current",
                "name": "Current Protection",
                "parentCategory": "category-iso-protection"
            },
            {
                "filterId": "subcategory-isopro-voltage",
                "name": "Voltage Protection",
                "parentCategory": "category-iso-protection"
            },
            {
                "filterId": "subcategory-isopro-emi",
                "name": "EMI Filters",
                "parentCategory": "category-iso-protection"
            },
            {
                "filterId": "subcategory-isopro-esd-diode",
                "name": "ESD Protection Diodes",
                "parentCategory": "category-iso-protection"
            },
            {
                "filterId": "subcategory-powerman-acdc",
                "name": "AC-DC Controllers & Regulators",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/ac_dc.svg",

                "parentCategory": "category-power-management"
            },
            {
                "filterId": "subcategory-powerman-battery",
                "name": "Battery Management",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/battery.svg",
                "parentCategory": "category-power-management"

            },
            {
                "filterId": "subcategory-powerman-load-switch",
                "name": "Load Switches",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/load_switches.svg",
                "parentCategory": "category-power-management"
            },
            {
                "filterId": "subcategory-powerman-dcdc",
                "name": "DC-DC Controllers, Converters, & Regulators",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/dc_dc.svg",
                "parentCategory": "category-power-management"
            },
            {
                "filterId": "subcategory-powerman-led",
                "name": "LED Drivers",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/led.svg",
                "parentCategory": "category-power-management"
            },
            {
                "filterId": "subcategory-powerman-motor-drive",
                "name": "Motor Drivers",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/motor_drivers.svg",
                "parentCategory": "category-power-management"
            },
            {
                "filterId": "subcategory-powerman-reference",
                "name": "Voltage References & Supervisors",
                "parentCategory": "category-power-management"
            },
            {
                "filterId": "subcategory-powermod-igbt",
                "name": "IGBT Modules",
                "parentCategory": "category-power-module"
            },
            {
                "filterId": "subcategory-powermod-mosfet",
                "name": "MOSFET Modules",
                "parentCategory": "category-power-module"
            },
            {
                "filterId": "subcategory-powermod-hybrid",
                "name": "Si/SiC Hybrid Modules",
                "parentCategory": "category-power-module"
            },
            {
                "filterId": "subcategory-powermod-ipm",
                "name": "Intelligent Power Modules (IPMs)",
                "parentCategory": "category-power-module"
            },
            {
                "filterId": "subcategory-interface-analog-switch",
                "name": "Analog Switches",
                "parentCategory": "category-interface"
            },
            {
                "filterId": "subcategory-interface-adc",
                "name": "Analog-to-Digital Converters (ADC)",
                "parentCategory": "category-interface"
            },
            {
                "filterId": "subcategory-interface-digital-pot",
                "name": "Digital Potentiometers (POTs)",
                "parentCategory": "category-interface"
            },
            {
                "filterId": "subcategory-interface-gfci",
                "name": "GFCI Controllers",
                "parentCategory": "category-interface"
            },
            {
                "filterId": "subcategory-interface-card-sim",
                "name": "Smart Card & SIM Card Interfaces",
                "parentCategory": "category-interface"
            },
            {
                "filterId": "subcategory-interface-usbc",
                "name": "USB Type-C",
                "iconSource": "qrc:/partial-views/platform-selector/images/icons/filter-icons/usb_type_c.svg",
                "parentCategory": "category-interface"
            },
            {
                "filterId": "subcategory-clock-generation",
                "name": "Clock Generation",
                "parentCategory": "category-clock-timing"
            },
            {
                "filterId": "subcategory-clock-distribution",
                "name": "Clock & Data Distribution",
                "parentCategory": "category-clock-timing"
            },
            {
                "filterId": "subcategory-discrete-audio",
                "name": "Audio Transistors",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-discrete-igbt",
                "name": "IGBTs",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-discrete-jfet",
                "name": "JFETs",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-discrete-diode",
                "name": "Diodes & Rectifiers",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-discrete-brt",
                "name": "Digital Transistors (BRTs)",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-discrete-gate-driver",
                "name": "Gate Drivers",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-discrete-mosfet",
                "name": "MOSFETs",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-discrete-darlington",
                "name": "Darlington Transistors",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-discrete-transistor",
                "name": "General Purpose and Low VCE(sat) Transistors",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-discrete-protected-mosfet",
                "name": "Protected MOSFETs",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-discrete-rf-transistor",
                "name": "RF Transistors",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-memory-eeprom",
                "name": "EEPROM Memory",
                "parentCategory": "category-discrete-driver"
            },
            {
                "filterId": "subcategory-memory-flash",
                "name": "Flash Memory",
                "parentCategory": "category-memory"
            },
            {
                "filterId": "subcategory-memory-sram",
                "name": "SRAM Memory",
                "parentCategory": "category-memory"
            },
            {
                "filterId": "subcategory-opto-high-performance",
                "name": "High Performance Optocouplers",
                "parentCategory": "category-memory"
            },
            {
                "filterId": "subcategory-opto-phototransistor",
                "name": "Phototransistor Optocouplers",
                "parentCategory": "category-optoelectronic"
            },
            {
                "filterId": "subcategory-opto-infrared",
                "name": "Infrared",
                "parentCategory": "category-optoelectronic"
            },
            {
                "filterId": "subcategory-opto-gate-drive",
                "name": "IGBT/MOSFET Gate Drivers Optocouplers",
                "parentCategory": "category-optoelectronic"
            },
            {
                "filterId": "subcategory-opto-triac",
                "name": "TRIAC Driver Optocouplers",
                "parentCategory": "category-optoelectronic"
            },
            {
                "filterId": "subcategory-micro-app-specific",
                "name": "Application Specific Microcontrollers",
                "parentCategory": "category-microcontroller"
            },
            {
                "filterId": "subcategory-micro-general",
                "name": "General Purpose Microcontrollers",
                "parentCategory": "category-microcontroller"
            },
            {
                "filterId": "subcategory-logic-arithmetic",
                "name": "Arithmetic Logic Functions",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-buffer",
                "name": "Buffers",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-bus",
                "name": "Bus Transceivers",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-flip-flop",
                "name": "D Flip-Flops and JK Flip-Flops",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-io-expander",
                "name": "I/O Expanders",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-latch-register",
                "name": "Latches & Registers",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-gates",
                "name": "Logic Gates",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-multiplexer",
                "name": "Multiplexers",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-level-translator",
                "name": "Level Translators",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-one-gate",
                "name": "1-Gate",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-two-gate",
                "name": "2-Gate",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-three-gate",
                "name": "3-Gate",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-ac",
                "name": "AC",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-act",
                "name": "ACT",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-alvc",
                "name": "ALVC",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-fst",
                "name": "Fast Switch Technology (FST) Switches",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-hc",
                "name": "HC",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-hct",
                "name": "HCT",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-lcx",
                "name": "LCX",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-lvx",
                "name": "LVX",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-metal-gate",
                "name": "Metal Gate",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-mini-gate",
                "name": "MiniGate",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-vcx",
                "name": "VCX",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-vhc",
                "name": "VHC",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "subcategory-logic-vhct",
                "name": "VHCT",
                "parentCategory": "category-standard-logic"
            },
            {
                "filterId": "status-connected",
                "name": "Connected",
            },
            {
                "filterId": "status-coming-soon",
                "name": "Coming Soon",
            },
            {
                "filterId": "status-recently-released",
                "name": "Recently Released",
            },
]

var mapping = {}
var activeFilters = []

var utility = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal activeFiltersChanged(); signal keywordFilterChanged();}', Qt.application, 'FiltersUtility');

function findFilter (filter) {
    if (mapping.hasOwnProperty(filter)) {
        if (mapping[filter].inUse === false){
            mapping[filter].filterName = filter
            filterModel.append(mapping[filter])
            mapping[filter].inUse = true
        }
        return mapping[filter]
    }
    return null
}

function getFilterList (filters) {
    let filterList = []
    for (let filter of filters) {
        let filterListItem = findFilter(filter)
        if (filterListItem) {
            filterList.push(filterListItem)
        } else {
            console.warn(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Ignoring unimplemented filter:", filter);
        }
    }

    return filterList
}

function initialize () {
    filterModel.clear()
    mapping = {}

    for (var i = 0; i < rawData.length; ++i) {
        var mappingItem = JSON.parse(JSON.stringify(rawData[i]))

        if (mappingItem.hasOwnProperty("iconSource") == false) {
            mappingItem["iconSource"] = "qrc:/partial-views/platform-selector/images/icons/placeholder.svg"
        }

        if (mappingItem.hasOwnProperty("parentCategory") == false) {
            mappingItem["parentCategory"] = ""
        }

        mappingItem["inUse"] = false
        mappingItem["activelyFiltering"] = false

        var type = ""
        if (mappingItem["filterId"].startsWith("segment-")) {
            type = "segment"
        } else if (mappingItem["filterId"].startsWith("category-") || mappingItem["filterId"].startsWith("subcategory-")) {
            type = "category"
        } else if (mappingItem["filterId"].startsWith("status-")) {
            type ="status"
        }
        mappingItem["type"] = type

        mapping[rawData[i]["filterId"]] = mappingItem
    }

    filterModel.append(mapping["status-connected"])
    filterModel.append(mapping["status-coming-soon"])
    filterModel.append(mapping["status-recently-released"])
}

function clearActiveFilters () {
    activeFilters = []
    utility.activeFiltersChanged()
}

function setFilterActive(filterId, active) {
    for (let i = 0; i < filterModel.count; i++){
        if (filterId === filterModel.get(i).filterId) {

            filterModel.get(i).activelyFiltering = active
            if (active) {
                addToActiveFilters(filterId)
            } else {
                removeFromActiveFilters(filterId)
            }
        }
    }
}

function addToActiveFilters(filterId) {
    for (let i = 0; i < activeFilters.length; i++){
        if (filterId === activeFilters[i]) {
            return
        }
    }
    activeFilters.push(filterId)
    utility.activeFiltersChanged()
}

function removeFromActiveFilters(filterName) {
    for (let i = 0; i < activeFilters.length; i++){
        if (filterName === activeFilters[i]) {
            activeFilters.splice(i, 1)
            utility.activeFiltersChanged()
            return
        }
    }
}

