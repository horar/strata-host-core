.pragma library
.import tech.strata.logger 1.0 as LoggerModule

var categoryFilterModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {}",Qt.application,"categoryFilterModel")
var segmentFilterModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {}",Qt.application,"segmentFilterModel")

var mapping = {
            "category-amplifier-comparator": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/amplifiers_and_comparators.svg",
                text: "Amplifiers & Comparators",
                type: "category",
                inUse: false
            },
            "category-audio-video": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
                text: "Audio/Video ASSP",
                type: "category",
                inUse: false
            },
            "category-connectivity": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/connectivity.svg",
                text: "Connectivity",
                type: "category",
                inUse: false
            },
            "category-sensor": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/sensors.svg",
                text: "Sensors",
                type: "category",
                inUse: false
            },
            "category-iso-protection": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/isolation_and_protection.svg",
                text: "Isolation & Protection Devices",
                type: "category",
                inUse: false
            },
            // Commented out per Will Abdeh request, to be uncommented in future release
//            "category-power-management": {
//                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/battery.svg",
//                text: "Power Management",
//                type: "category",
//                inUse: false
//            },
            "subcategory-powerman-load-switch": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/load_switches.svg",
                text: "Load Switches",
                type: "category",
                inUse: false
            },
            "category-power-module": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/battery.svg",
                text: "Power Modules",
                type: "category",
                inUse: false
            },
            "category-interface": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/interfaces.svg",
                text: "Interfaces",
                type: "category",
                inUse: false
            },
            "category-clock-timing": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
                text: "Clock & Timing",
                type: "category",
                inUse: false
            },
            "category-discrete-driver": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/discretes_and_drivers.svg",
                text: "Discretes & Drivers",
                type: "category",
                inUse: false
            },
            "category-memory": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/memory.svg",
                text: "Memory",
                type: "category",
                inUse: false
            },
            "category-optoelectronic": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
                text: "Optoelectronics",
                type: "category",
                inUse: false
            },
            "category-microcontroller": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
                text: "Microcontrollers",
                type: "category",
                inUse: false
            },
            "category-standard-logic": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/logic_gates.svg",
                text: "Standard Logic",
                type: "category",
                inUse: false
            },
            "subcategory-powerman-dcdc": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/dc_dc.svg",
                text: "DC-DC Controllers, Converters, & Regulators",
                type: "category",
                inUse: false
            },
            "subcategory-powerman-acdc": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/ac_dc.svg",
                text: "AC-DC Controllers & Regulators",
                type: "category",
                inUse: false
            },
            "subcategory-powerman-led": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/led.svg",
                text: "LED Drivers",
                type: "category",
                inUse: false
            },
            "subcategory-powerman-motor-drive": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/motor_drivers.svg",
                text: "Motor Drivers",
                type: "category",
                inUse: false
            },
            "subcategory-interface-usbc": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/usb_type_c.svg",
                text: "USB Type-C",
                type: "category",
                inUse: false
            },

            // Segments
            "segment-automotive": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-automotive.svg",
                text: "Automotive",
                type: "segment",
                inUse: false
            },
            "segment-iot": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-iot.svg",
                text: "Internet<br>of Things",
                type: "segment",
                inUse: false
            },
            "segment-industrial-cloud-power": {
                iconSource: "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-industrial-cloud-power.svg",
                text: "Industrial & <br>Cloud Power",
                type: "segment",
                inUse: false
            },
        }


var categoryFilters = []
var segmentFilter = ""
var keywordFilter = ""

var utility = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal categoryFiltersChanged(); signal segmentFilterChanged(); signal keywordFilterChanged();}', Qt.application, 'FiltersUtility');

function findFilter (filter) {
    if (mapping.hasOwnProperty(filter)) {
        if (mapping[filter].inUse === false){
            mapping[filter].filterName = filter
            if (mapping[filter].type === "category") {
                categoryFilterModel.append(mapping[filter])
            } else if (mapping[filter].type === "segment") {
                segmentFilterModel.append(mapping[filter])
            }
            mapping[filter].inUse = true
        }
        return mapping[filter]
    }
    return null
}

function getFilterList (filters) {
    let filterModel = []
    for (let filter of filters) {
        let filterListItem = findFilter(filter)
        if (filterListItem) {
            filterModel.push(filterListItem)
        } else {
            console.warn(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Ignoring unimplemented filter:", filter);
        }
    }
    return filterModel
}

function initialize () {
    for (let property in mapping) {
        mapping[property].inUse = false
    }
    categoryFilterModel.clear()
    segmentFilterModel.clear()
}

function clearActiveFilters () {
    categoryFilters = []
    segmentFilter = ""
    keywordFilter = ""
    utility.categoryFiltersChanged()
    utility.segmentFilterChanged()
    utility.keywordFilterChanged()
}
