.pragma library

var documentEmbeddedSchema = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "class_id": {"type": "string"},
        "controller_type": {"type": "integer"},
        "mcu": {
            "type": "object",
            "properties": {
                "jlink_device": {"type": "string"},
                "bootloader_start_address": {"type": "integer"}
            },
            "required": ["jlink_device", "bootloader_start_address"]
        },
        "firmware": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "file": {"type": "string"},
                    "filename": {"type": "string"},
                    "filesize": {"type": "integer"},
                    "md5": {"type": "string"},
                    "timestamp": {"type": "string"},
                    "version": {  "type": "string"}
                },
                "required": ["file", "md5", "timestamp", "version"]
            }
        },
        "bootloader": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "file": {"type": "string"},
                    "filename": {"type": "string"},
                    "filesize": {"type": "integer"},
                    "md5": {"type": "string"},
                    "timestamp": {"type": "string"},
                    "version": {  "type": "string"}
                },
                "required": [
                    "file",
                    "md5",
                    "timestamp",
                    "version"
                ]
            }
        }
    },
    "required": ["class_id", "controller_type", "mcu", "firmware", "bootloader"]
}

var documentAssistedSchema = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "class_id": {"type": "string"},
        "controller_type": {"type": "integer"},
        "firmware": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "file": {"type": "string"},
                    "filename": {"type": "string"},
                    "filesize": {"type": "integer"},
                    "md5": {"type": "string"},
                    "timestamp": {"type": "string"},
                    "version": {  "type": "string"},
                    "controller_class_id": {  "type": "string"}
                },
                "required": ["file", "md5", "timestamp", "version", "controller_class_id"]
            }
        }
    },
    "required": ["class_id", "controller_type", "firmware"]
}

var documentControllerSchema = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "class_id": {"type": "string"},
        "controller_type": {"type": "integer"},
        "mcu": {
            "type": "object",
            "properties": {
                "jlink_device": {"type": "string"},
                "bootloader_start_address": {"type": "integer"}
            },
            "required": ["jlink_device", "bootloader_start_address"]
        },
        "bootloader": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "file": {"type": "string"},
                    "filename": {"type": "string"},
                    "filesize": {"type": "integer"},
                    "md5": {"type": "string"},
                    "timestamp": {"type": "string"},
                    "version": {  "type": "string"}
                },
                "required": [
                    "file",
                    "md5",
                    "timestamp",
                    "version"
                ]
            }
        }
    },
    "required": ["class_id", "controller_type", "mcu", "bootloader"]
}
