/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    "required": ["class_id", "controller_type", "mcu"]
}

var documentAssistedSchema = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "opn": {"type": "string"},
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
    "required": ["opn", "class_id", "controller_type"]
}

var documentControllerSchema = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "opn": {"type": "string"},
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
    "required": ["opn", "class_id", "controller_type", "mcu"]
}

/* fake data for testing until cloud service can provide proper data */

var fakeEmbeddedData = {
    "opn": "STR-EMBEDDED",
    "class_id": "ffe2f2c2-3ba8-45f4-b481-379b9d9b5622",
    "controller_type": 1,
    "mcu": {
        "jlink_device": "EFM32GG380F1024",
        "bootloader_start_address": 0
    },
    "firmware": [
        {
            "file": "ota/0bbcc07e14c0b711db1711e834c6268e.bin",
            "filesize": 1000,
            "md5": "0bbcc07e14c0b711db1711e834c6268e",
            "timestamp": "2020-10-21T01:10:10.000Z",
            "version": "1.0.0"
        },
        {
            "file": "ota/0bbcc07e14c0b711db1711e834c6268e.bin",
            "filesize": 1000,
            "md5": "0bbcc07e14c0b711db1711e834c6268e",
            "timestamp": "2020-10-25T01:23:18.969Z",
            "version": "1.1.0"
        },
        {
            "file": "ota/0bbcc07e14c0b711db1711e834c6268e.bin",
            "filesize": 1000,
            "md5": "0bbcc07e14c0b711db1711e834c6268e",
            "timestamp": "2020-10-28T02:10:10.000Z",
            "version": "1.0.1"
        }
    ],
    "bootloader": [
        {
            "file": "ota/0bbcc07e14c0b711db1711e834c6268e.bin",
            "filesize": 1000,
            "md5": "0bbcc07e14c0b711db1711e834c6268e",
            "timestamp": "2020-10-22T01:23:18.969Z",
            "version": "1.0.0"
        },
        {
            "file": "ota/0bbcc07e14c0b711db1711e834c6268e.bin",
            "filesize": 1000,
            "md5": "0bbcc07e14c0b711db1711e834c6268e",
            "timestamp": "2021-02-22T01:10:10.969Z",
            "version": "1.0.2"
        }
    ]
}

var fakeAssistedData = {
    "opn": "STR-ASSISTED",
    "class_id": "aae2f2c2-3ba8-45f4-b481-379b9d9b56aa",
    "controller_type": 2,
    "firmware": [
        {
            "file": "ota/0bbcc07e14c0b711db1711e834c6268e.bin",
            "filesize": 1000,
            "md5": "0bbcc07e14c0b711db1711e834c6268e",
            "timestamp": "2020-10-22T01:23:18.969Z",
            "version": "1.1.2",
            "controller_class_id": "cce2f2c2-3ba8-45f4-b481-379b9d9b56cc"
        }
    ]
}

var fakeControllerData = {
    "opn": "STR-CONTROLLER",
    "class_id": "cce2f2c2-3ba8-45f4-b481-379b9d9b56cc",
    "controller_type": 3,
    "mcu": {
        "jlink_device": "EFM32GG380F1024",
        "bootloader_start_address": 0
    },
    "bootloader": [
        {
            "file": "ota/0bbcc07e14c0b711db1711e834c6268e.bin",
            "filesize": 1000,
            "md5": "0bbcc07e14c0b711db1711e834c6268e",
            "timestamp": "2020-10-22T01:23:18.969Z",
            "version": "1.0.0"
        }
    ]
}
