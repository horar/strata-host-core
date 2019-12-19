.pragma library

var categoryFilterModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {}",Qt.application,"categoryFilterModel")
var segmentFilterModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {}",Qt.application,"segmentFilterModel")

var mapping = [
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/dc_dc_controllers_converters_and_regulators.svg",
                text: "DC-DC Converters",
                filterMapping: "category-dc-dc",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/dc_dc_controllers_converters_and_regulators.svg",
                text: "LDO Regulators & Linear Voltage Regulators",
                filterMapping: "category-ldo",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/offline_controllers.svg",
                text: "Offline Controllers",
                filterMapping: "category-offline-controllers",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/load_switches.svg",
                text: "Load Switches",
                filterMapping: "category-load-switches",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/led.svg",
                text: "LED Drivers",
                filterMapping: "category-led-drivers",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/isolation_and_protection.svg",
                text: "eFuses",
                filterMapping: "category-efuses",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/discretes_and_drivers.svg",
                text: "Discretes & Drivers",
                filterMapping: "category-discretes-drivers",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/usb.svg",
                text: "USB",
                filterMapping: "category-usb",
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
                filterMapping: "category-sensors",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/motor_drivers.svg",
                text: "Motor Drivers",
                filterMapping: "category-motor-drivers",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/analog_to_digital_converters.svg",
                text: "Analog-to-Digital Converters (ADC)",
                filterMapping: "category-adc",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/amplifiers_and_comparators.svg",
                text: "Amplifiers & Comparators",
                filterMapping: "category-amplifiers-comparators",
                type: "category",
                inUse: false
            },
            {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/logic_gates.svg",
                text: "Logic Gates",
                filterMapping: "category-logic-gates",
                type: "category",
                inUse: false
            },
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
            }
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

// TODO [Faller] - remove when Deployment Portal API is updated to use filters key
var oldNewMap = {
    "automotive": "segment-automotive",
    "industrial": "segment-industrial-cloud-power",
    "wirelessiot": "segment-iot",

    "analog": "category-adc",
    "connectivity": "category-connectivity",
    "dc": "category-dc-dc",
    "discrete": "category-discretes-drivers",
    "led": "category-led-drivers",
    "sensor": "category-sensors",
}
