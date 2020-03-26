.pragma library

var categoryFilterModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {}",Qt.application,"categoryFilterModel")
var segmentFilterModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {}",Qt.application,"segmentFilterModel")

var mapping = [
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/amplifiers_and_comparators.svg",
                text: "Amplifiers & Comparators",
                filterMapping: "category-amplifier-comparator",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
                text: "Audio/Video ASSP",
                filterMapping: "category-audio-video",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/connectivity.svg",
                text: "Connectivity",
                filterMapping: "category-connectivity",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/sensors.svg",
                text: "Sensors",
                filterMapping: "category-sensor",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/isolation_and_protection.svg",
                text: "Isolation & Protection Devices",
                filterMapping: "category-iso-protection",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/battery.svg",
                text: "Power Management",
                filterMapping: "category-power-management",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/battery.svg",
                text: "Power Modules",
                filterMapping: "category-power-module",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/analog_to_digital_converters.svg",
                text: "Interfaces",
                filterMapping: "category-interface",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
                text: "Clock & Timing",
                filterMapping: "category-clock-timing",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/discretes_and_drivers.svg",
                text: "Discretes & Drivers",
                filterMapping: "category-discrete-driver",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/memory.svg",
                text: "Memory",
                filterMapping: "category-memory",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
                text: "Optoelectronics",
                filterMapping: "category-optoelectronic",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
                text: "Microcontrollers",
                filterMapping: "category-microcontroller",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/logic_gates.svg",
                text: "Standard Logic",
                filterMapping: "category-standard-logic",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/dc_dc.svg",
                text: "DC-DC Controllers, Converters, & Regulators",
                filterMapping: "subcategory-powerman-dcdc",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/ac_dc.svg",
                text: "AC-DC Controllers & Regulators",
                filterMapping: "subcategory-powerman-acdc",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/led.svg",
                text: "LED Drivers",
                filterMapping: "category-powerman-led",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/motor_drivers.svg",
                text: "Motor Drivers",
                filterMapping: "subcategory-powerman-motor-drive",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/usb.svg",
                text: "USB Type-C",
                filterMapping: "subcategory-usb",
                type: "category",
                inUse: false
            },

            // Segments
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-automotive.svg",
                text: "Automotive",
                filterMapping: "segment-automotive",
                type: "segment",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-iot.svg",
                text: "Internet<br>of Things",
                filterMapping: "segment-iot",
                type: "segment",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-industrial-cloud-power.svg",
                text: "Industrial & <br>Cloud Power",
                filterMapping: "segment-industrial-cloud-power",
                type: "segment",
                inUse: false
            },

            // TODO [Faller] - remove when Deployment Portal API is updated to use filters key - see also note in oldNewMap
            // The following 2 categories are just for interim compatibility for release 2.0.0 along with placeholder icons above
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/analog_to_digital_converters.svg",
                text: "Analog-to-Digital Converters (ADC)",
                filterMapping: "category-adc",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/battery.svg",
                text: "DC-DC Converters",
                filterMapping: "category-dc-dc",
                type: "category",
                inUse: false
            },
        ]


var categoryFilters = []
var segmentFilter = ""
var keywordFilter = ""

var utility = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal categoryFiltersChanged(); signal segmentFilterChanged(); }', Qt.application, 'FiltersUtility');

function findFilter (filter) {
    for (let i=0; i< mapping.length; i++) {
        if (mapping[i].filterMapping === filter) {
            if (!mapping[i].inUse){
                if (mapping[i].type === "category") {
                    categoryFilterModel.append(mapping[i])
                } else if (mapping[i].type === "segment") {
                    segmentFilterModel.append(mapping[i])
                }
                mapping[i].inUse = true
            }
            return mapping[i]
        }
    }
    return null
}

function initialize () {
    for (let i=0; i< mapping.length; i++) {
        mapping[i].inUse = false
    }
    categoryFilterModel.clear()
    segmentFilterModel.clear()
}

function clearActiveFilters () {
    categoryFilters = []
    segmentFilter = ""
    keywordFilter = ""
}

// TODO [Faller] - remove when Deployment Portal API is updated to use filters key - see also the note in 'mapping' above
var oldNewMap = {
    "automotive": "segment-automotive",
    "industrial": "segment-industrial-cloud-power",
    "wirelessiot": "segment-iot",

    "analog": "category-adc",
    "connectivity": "category-connectivity",
    "dc": "category-dc-dc",
    "discrete": "category-discrete-driver",
    "led": "category-powerman-led",
    "sensor": "category-sensor",
}
