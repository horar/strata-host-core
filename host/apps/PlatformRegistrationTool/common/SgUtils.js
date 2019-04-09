.pragma library

function createDialog(url, parent) {
    var component = Qt.createComponent(url, parent)
    if (component) {
        var obj = component.createObject(parent)
        var pos = centreObject(obj, parent)

        obj.x = pos.x
        obj.y = pos.y

        return obj
    }
}

function centreObject(object, parent) {
    var pos = {}

    pos["x"] = Math.round((parent.width - object.width) / 2)
    pos["y"] = Math.round((parent.height - object.height) / 2)

    return pos
}

function resolveTag(tag, prop) {
    if (default_tags.hasOwnProperty(tag)) {
        var ret = default_tags[tag][prop]
        if (ret) {
            return ret
        } else if (prop === "description") {
            return "Description for " + tag + " is not available now."
        }
    }
}

var default_tags = {
    "ac": {
        "text": "AC",
        "icon": "qrc:/images/tag_icons/ac.svg",
        "description": "Alternating Current.",
    },
    "analog": {
        "text": "Analog",
        "icon": "qrc:/images/tag_icons/analog.svg",
        "description": "",
    },
    "audio": {
        "text": "Audio",
        "icon": "qrc:/images/tag_icons/audio.svg",
        "description": "",
    },
    "connectivity": {
        "text": "Connectivity",
        "icon": "qrc:/images/tag_icons/connectivity.svg",
        "description": "",
    },
    "dc": {
        "text": "DC",
        "icon": "qrc:/images/tag_icons/dc.svg",
        "description": "Direct Current.",
    },
    "digital": {
        "text": "Digital",
        "icon": "qrc:/images/tag_icons/digital.svg",
        "description": "",
    },
    "discrete": {
        "text": "Discrete",
        "icon": "qrc:/images/tag_icons/discrete.svg",
        "description": "",
    },
    "esd": {
        "text": "ESD",
        "icon": "qrc:/images/tag_icons/esd.svg",
        "description": "Electrostatic Discharge.",
    },
    "imagesensors": {
        "text": "Image Sensors",
        "icon": "qrc:/images/tag_icons/imagesensors.svg",
        "description": "",
    },
    "infrared": {
        "text": "Infrared",
        "icon": "qrc:/images/tag_icons/infrared.svg",
        "description": "",
    },
    "led": {
        "text": "LED",
        "icon": "qrc:/images/tag_icons/led.svg",
        "description": "",
    },
    "mcu": {
        "text": "MCU",
        "icon": "qrc:/images/tag_icons/mcu.svg",
        "description": "",
    },
    "memory": {
        "text": "Memory",
        "icon": "qrc:/images/tag_icons/memory.svg",
        "description": "",
    },
    "optoisolator": {
        "text": "Optoisolator",
        "icon": "qrc:/images/tag_icons/optoisolator.svg",
        "description": "",
    },
    "pm": {
        "text": "PM",
        "icon": "qrc:/images/tag_icons/pm.svg",
        "description": "",
    },
    "sensor": {
        "text": "Sensor",
        "icon": "qrc:/images/tag_icons/sensor.svg",
        "description": "",
    },
    "video": {
        "text": "Video",
        "icon": "qrc:/images/tag_icons/video.svg",
        "description": "",
    },
    "automotive": {
        "text": "Automotive",
        "icon": "qrc:/images/tag_icons/automotive.svg",
        "description": "Relating to or concerned with motor vehicles.",
    },
    "computing": {
        "text": "Computing",
        "icon": "qrc:/images/tag_icons/computing.svg",
        "description": "",
    },
    "consumer": {
        "text": "Consumer",
        "icon": "qrc:/images/tag_icons/consumer.svg",
        "description": "",
    },
    "industrial": {
        "text": "Industrial",
        "icon": "qrc:/images/tag_icons/industrial.svg",
        "description": "",
    },
    "ledlighting": {
        "text": "LED Lighting",
        "icon": "qrc:/images/tag_icons/ledlighting.svg",
        "description": "",
    },
    "medical": {
        "text": "Medical",
        "icon": "qrc:/images/tag_icons/medical.svg",
        "description": "",
    },
    "militaryaerospace": {
        "text": "Military Aerospace",
        "icon": "qrc:/images/tag_icons/militaryaerospace.svg",
        "description": "",
    },
    "motorcontrol": {
        "text": "Motor Control",
        "icon": "qrc:/images/tag_icons/motorcontrol.svg",
        "description": "",
    },
    "networkingtelecom": {
        "text": "Network Telecom",
        "icon": "qrc:/images/tag_icons/networkingtelecom.svg",
        "description": "",
    },
    "powersupply": {
        "text": "Power Supply",
        "icon": "qrc:/images/tag_icons/powersupply.svg",
        "description": "",
    },
    "whitegoods": {
        "text": "White Goods",
        "icon": "qrc:/images/tag_icons/whitegoods.svg",
        "description": "A large machine in home appliance used for routine housekeeping tasks such as cooking, washing laundry, or food preservation.",
    },
    "wirelessiot": {
        "text": "Wireless IoT",
        "icon": "qrc:/images/tag_icons/wirelessiot.svg",
        "description": "",
    }
}
