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

var mapping = {
    "category-amplifier-comparator": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/amplifiers_and_comparators.svg",
        text: "Amplifiers & Comparators",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-audio-video": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
        text: "Audio/Video ASSP",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-connectivity": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/connectivity.svg",
        text: "Connectivity",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-sensor": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/sensors.svg",
        text: "Sensors",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-iso-protection": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/isolation_and_protection.svg",
        text: "Isolation & Protection Devices",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "subcategory-powerman-battery": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/battery.svg",
        text: "Battery Management",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "subcategory-powerman-load-switch": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/load_switches.svg",
        text: "Load Switches",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-power-module": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/battery.svg",
        text: "Power Modules",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-interface": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/interfaces.svg",
        text: "Interfaces",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-clock-timing": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
        text: "Clock & Timing",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-discrete-driver": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/discretes_and_drivers.svg",
        text: "Discretes & Drivers",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-memory": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/memory.svg",
        text: "Memory",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-optoelectronic": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
        text: "Optoelectronics",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-microcontroller": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/placeholder.svg",
        text: "Microcontrollers",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "category-standard-logic": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/logic_gates.svg",
        text: "Standard Logic",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "subcategory-powerman-dcdc": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/dc_dc.svg",
        text: "DC-DC Controllers, Converters, & Regulators",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "subcategory-powerman-acdc": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/ac_dc.svg",
        text: "AC-DC Controllers & Regulators",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "subcategory-powerman-led": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/led.svg",
        text: "LED Drivers",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "subcategory-powerman-motor-drive": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/motor_drivers.svg",
        text: "Motor Drivers",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "subcategory-interface-usbc": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/filter-icons/usb_type_c.svg",
        text: "USB Type-C",
        type: "category",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },

    // Segments
    "segment-automotive": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-automotive.svg",
        text: "Automotive",
        type: "segment",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "segment-iot": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-iot.svg",
        text: "Internet of Things",
        type: "segment",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },
    "segment-industrial-cloud-power": {
        iconSource: "qrc:/partial-views/platform-selector/images/icons/segment-icons/segment-industrial-cloud-power.svg",
        text: "Industrial & Cloud Power",
        type: "segment",
        inUse: false,
        activelyFiltering: false,
        row: -1
    },

    // Statuses
    "status-connected": {
        iconSource: "",
        text: "Connected",
        type: "status",
        inUse: false,
        activelyFiltering: false,
        filterName: "status-connected",
        row: -1
    },
    "status-coming-soon": {
        iconSource: "",
        text: "Coming Soon",
        type: "status",
        inUse: false,
        activelyFiltering: false,
        filterName: "status-coming-soon",
        row: -1
    },
    "status-recently-released": {
        iconSource: "",
        text: "Recently Released",
        type: "status",
        inUse: false,
        activelyFiltering: false,
        filterName: "status-recently-released",
        row: -1
    },
}


var activeFilters = []
var keywordFilter = ""

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
    filterModel.clear()

    filterModel.append(mapping["status-connected"])
    filterModel.append(mapping["status-coming-soon"])
    filterModel.append(mapping["status-recently-released"])
}

function clearActiveFilters () {
    activeFilters = []
    keywordFilter = ""
    utility.activeFiltersChanged()
    utility.keywordFilterChanged()
}

function setFilterActive(filterName, active) {
    for (let i = 0; i < filterModel.count; i++){
        if (filterName === filterModel.get(i).filterName) {
            filterModel.get(i).activelyFiltering = active
            if (active) {
                addToActiveFilters(filterName)
            } else {
                removeFromActiveFilters(filterName)
            }
        }
    }
}

function addToActiveFilters(filterName) {
    for (let i = 0; i < activeFilters.length; i++){
        if (filterName === activeFilters[i]) {
            return
        }
    }
    activeFilters.push(filterName)
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

