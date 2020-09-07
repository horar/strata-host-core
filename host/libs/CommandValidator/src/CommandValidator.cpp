#include "CommandValidator.h"

#include <iostream>
#include <rapidjson/writer.h>
#include <rapidjson/error/en.h>

// define the schemas

// this support platform id v2 only.
const rapidjson::SchemaDocument CommandValidator::requestPlatformIdResSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": {
                "notification": {
                    "type": "object",
                    "properties": {
                        "value": {
                            "pattern": "^platform_id$"
                        },
                        "payload": {
                            "type": "object",
                            "properties": {
                                "name": {
                                    "type": "string"
                                },
                                "verbose_name": {
                                    "type": "string"
                                },
                                "platform_id": {
                                    "type": "string"
                                },
                                "class_id": {
                                    "type": "string"
                                },
                                "count": {
                                    "type": [
                                        "string",
                                        "integer"
                                    ]
                                },
                                "platform_id_version": {
                                    "type": "string"
                                }
                            },
                            "required": [
                                "name",
                                "platform_id",
                                "class_id",
                                "count",
                                "platform_id_version"
                            ]
                        }
                    },
                    "required": [
                        "value",
                        "payload"
                    ]
                }
            },
            "required": [
                "notification"
            ]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::ackSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": {
                "ack": {
                "type": "string"
                },
                "payload": {
                "type": "object",
                "properties": {
                    "return_value": {
                    "type": "boolean"
                    },
                    "return_string": {
                    "type": "string"
                    }
                },
                "required": [
                    "return_value",
                    "return_string"
                ]
                }
            },
            "required": [
                "ack",
                "payload"
            ]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::cmdSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": {
                "cmd": {
                "type": "string"
                },
                "payload": {
                "type": "object"
                }
            },
            "required": [
                "cmd"
            ]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::notificationSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": {
            "notification": {
                "type": "object",
                "properties": {
                "value": {
                    "type": "string"
                },
                "payload": {
                    "type": "object"
                }
                },
                "required": [
                "value",
                "payload"
                ]
            }
            },
            "required": [
            "notification"
            ]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::setPlatformIdResSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": {
                "notification": {
                "type": "object",
                "properties": {
                    "value": {
                    "type": "string",
                    "pattern":"^set_platform_id$"
                    },
                    "payload": {
                    "type": "object",
                    "properties": {
                        "status": {
                        "type": "string"
                        }
                    },
                    "required": [
                        "status"
                    ]
                    }
                },
                "required": [
                    "value",
                    "payload"
                ]
                }
            },
            "required": [
                "notification"
            ]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::startBootloaderResSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": {
            "notification": {
                "type": "object",
                "properties": {
                "value": {
                    "type": "string",
                    "pattern": "^start_bootloader$"
                },
                "payload": {
                    "type": "object",
                    "properties": {
                    "status": {
                        "type": "string"
                    }
                    },
                    "required": [
                    "status"
                    ]
                }
                },
                "required": [
                "value",
                "payload"
                ]
            }
            },
            "required": [
            "notification"
            ]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::startFlashFirmwareResSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": {
            "notification": {
                "type": "object",
                "properties": {
                "value": {
                    "type": "string",
                    "pattern": "^start_flash_firmware$"
                },
                "payload": {
                    "type": "object",
                    "properties": {
                    "status": {
                        "type": "string"
                    }
                    },
                    "required": [
                    "status"
                    ]
                }
                },
                "required": [
                "value",
                "payload"
                ]
            }
            },
            "required": [
            "notification"
            ]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::flashFirmwareResSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": {
            "notification": {
                "type": "object",
                "properties": {
                "value": {
                    "type": "string",
                    "pattern": "^flash_firmware$"
                },
                "payload": {
                    "type": "object",
                    "properties": {
                    "status": {
                        "type": "string"
                    }
                    },
                    "required": [
                    "status"
                    ]
                }
                },
                "required": [
                "value",
                "payload"
                ]
            }
            },
            "required": [
            "notification"
            ]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::startBackupFirmwareResSchema(
    CommandValidator::parseSchema(
        R"(
        {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "type": "object",
          "properties": {
            "notification": {
            "type": "object",
              "properties": {
                "value": {
                  "type": "string",
                  "pattern": "^start_backup_firmware$"
                },
                "payload": {
                  "oneOf": [
                    {
                      "type": "object",
                      "properties": {
                        "size": {"type": "number"},
                        "chunks": {"type": "number"}
                      },
                      "required": ["size", "chunks"]
                    },
                    {
                      "type": "object",
                      "properties": {
                        "status": {"type": "string"}
                      },
                      "required": ["status"]
                    }
                  ]
                }
              },
              "required": ["value", "payload"]
            }
          },
          "required": ["notification"]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::backupFirmwareResSchema(
    CommandValidator::parseSchema(
        R"(
        {
          "$schema": "http://json-schema.org/draft-04/schema#",
          "type": "object",
          "properties": {
            "notification": {
              "type": "object",
              "properties": {
                "value": {
                  "type": "string",
                  "pattern": "^backup_firmware$"
                },
                "payload": {
                  "type": "object",
                  "properties": {
                    "chunk": {
                      "type": "object",
                      "properties": {
                        "number": {"type": "number"},
                        "size": {"type": "number"},
                        "crc": {"type": "number"},
                        "data": {"type": "string"}
                      },
                      "required": ["number", "size", "crc", "data"]
                    }
                  },
                  "required": ["chunk"]
                }
              },
              "required": ["value", "payload"]
            }
          },
          "required": ["notification"]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::flashBootloaderResSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": {
            "notification": {
                "type": "object",
                "properties": {
                "value": {
                    "type": "string",
                    "pattern": "^flash_bootloader$"
                },
                "payload": {
                    "type": "object",
                    "properties": {
                    "status": {
                        "type": "string"
                    }
                    },
                    "required": [
                    "status"
                    ]
                }
                },
                "required": [
                "value",
                "payload"
                ]
            }
            },
            "required": [
            "notification"
            ]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::startAppResSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": {
            "notification": {
                "type": "object",
                "properties": {
                "value": {
                    "type": "string",
                    "pattern": "^start_application$"
                },
                "payload": {
                    "type": "object",
                    "properties": {
                    "status": {
                        "type": "string"
                    }
                    },
                    "required": [
                    "status"
                    ]
                }
                },
                "required": [
                "value",
                "payload"
                ]
            }
            },
            "required": [
            "notification"
            ]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::getFirmwareInfoResSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "properties": {
            "notification": {
                "type": "object",
                "properties": {
                "value": {
                    "type": "string",
                    "pattern": "^get_firmware_info$"
                },
                "payload": {
                    "type": "object",
                    "properties": {
                    "bootloader": {
                        "oneOf": [
                            {
                                "type": "object",
                                "additionalProperties": false
                            },
                            {
                                "type": "object",
                                "properties": {
                                    "version": {
                                        "type": "string"
                                    },
                                    "date": {
                                        "type": "string"
                                    }
                                },
                                "required": [
                                    "version",
                                    "date"
                                ]
                            }
                        ]
                    },
                    "application": {
                        "oneOf": [
                            {
                                "type": "object",
                                "additionalProperties": false
                            },
                            {
                                "type": "object",
                                "properties": {
                                    "version": {
                                        "type": "string"
                                    },
                                    "date": {
                                        "type": "string"
                                    }
                                },
                                "required": [
                                    "version",
                                    "date"
                                ]
                            }
                        ]
                    }
                    },
                    "required": [
                    "bootloader",
                    "application"
                    ]
                }
                },
                "required": [
                "value",
                "payload"
                ]
            }
            },
            "required": [
            "notification"
            ]
        })"
    )
);

const rapidjson::SchemaDocument CommandValidator::strataCommandSchema(
    CommandValidator::parseSchema(
        R"(
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "type": "object",
            "oneOf": [
                {
                "properties": {
                    "cmd": {
                    "type": "string"
                    },
                    "payload": {
                    "type": "object"
                    }
                },
                "required": [
                    "cmd"
                ]
                },
                {
                "properties": {
                    "notification": {
                    "type": "object",
                    "properties": {
                        "value": {
                        "type": "string"
                        },
                        "payload": {
                        "type": "object"
                        }
                    },
                    "required": [
                        "value",
                        "payload"
                    ]
                    }
                },
                "required": [
                    "notification"
                ]
                },
                {
                "properties": {
                    "ack": {
                    "type": "string"
                    },
                    "payload": {
                    "type": "object",
                    "properties": {
                        "return_value": {
                        "type": "boolean"
                        },
                        "return_string": {
                        "type": "string"
                        }
                    },
                    "required": [
                        "return_value",
                        "return_string"
                    ]
                    }
                },
                "required": [
                    "ack",
                    "payload"
                ]
                }
            ]
        })"
    )
);

const std::map<const CommandValidator::JsonType, const rapidjson::SchemaDocument&> CommandValidator::schemas = {
    {JsonType::reqPlatIdRes, requestPlatformIdResSchema},
    {JsonType::setPlatIdRes, setPlatformIdResSchema},
    {JsonType::ack, ackSchema},
    {JsonType::notification, notificationSchema},
    {JsonType::getFirmwareInfoRes, getFirmwareInfoResSchema},
    {JsonType::startBootloaderRes, startBootloaderResSchema},
    {JsonType::startFlashFirmwareRes, startFlashFirmwareResSchema},
    {JsonType::flashFirmwareRes, flashFirmwareResSchema},
    {JsonType::startBackupFirmwareRes, startBackupFirmwareResSchema},
    {JsonType::backupFirmwareRes, backupFirmwareResSchema},
    {JsonType::flashBootloaderRes, flashBootloaderResSchema},
    {JsonType::startAppRes, startAppResSchema},
    {JsonType::strataCmd, strataCommandSchema},
    {JsonType::cmd, cmdSchema}
};

rapidjson::SchemaDocument CommandValidator::parseSchema(const std::string &schema, bool *isOk) {
    bool ok = true;
    rapidjson::Document sd;
    rapidjson::ParseResult result = sd.Parse(schema.c_str());
    if (result.IsError()) {
        // TODO: use logger from CS-440
        std::cerr << "JSON parse error at offset " << result.Offset() << ": " << rapidjson::GetParseError_En(result.Code())
                  << " Invalid JSON schema: '" << schema << "'" << std::endl;
        ok = false;
    }

    if (isOk) {
        *isOk = ok;
    }
    return rapidjson::SchemaDocument(sd);
}

bool CommandValidator::validateDocWithSchema(const rapidjson::SchemaDocument &schema, const rapidjson::Document &doc) {
    rapidjson::SchemaValidator validator(schema);

    if (doc.Accept(validator) == false) {
        rapidjson::StringBuffer buffer;
        rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);

        doc.Accept(writer);
        std::string command = buffer.GetString();

        buffer.Clear();
        writer.Reset(buffer);

        validator.GetError().Accept(writer);
        // TODO: use logger from CS-440
        std::cerr << "Command '" << command << "' is not valid by required schema: " << buffer.GetString() << std::endl;
        return false;
    }

    return true;
}

bool CommandValidator::validate(const std::string &command, const JsonType type, rapidjson::Document &doc) {
    if (parseJsonCommand(command, doc) == false) {
        return false;
    }

    return validate(type, doc);
}

bool CommandValidator::validate(const std::string &command, const std::string& schema, rapidjson::Document &doc) {
    if (parseJsonCommand(command, doc) == false) {
        return false;
    }

    bool isOk = false;
    rapidjson::SchemaDocument schemaDoc = parseSchema(schema, &isOk);
    if (isOk == false) {
        return false;
    }

    return validateDocWithSchema(schemaDoc, doc);
}

bool CommandValidator::validate(const JsonType type, const rapidjson::Document &doc) {
  const auto it = schemas.find(type);
  if (it == schemas.end()) {
      // TODO: use logger from CS-440
      std::cerr << "Unknown schema (" << static_cast<int>(type) << ")." << std::endl;
      return false;
  }

  return validateDocWithSchema(it->second, doc);
}

bool CommandValidator::isValidJson(const std::string &command) {
    return (rapidjson::Document().Parse(command.c_str()).HasParseError() == false);
}

bool CommandValidator::parseJsonCommand(const std::string &command, rapidjson::Document &doc) {
    rapidjson::ParseResult result = doc.Parse(command.c_str());
    if (result.IsError()) {
        // TODO: use logger from CS-440
        std::cerr << "JSON parse error at offset " << result.Offset() << ": " << rapidjson::GetParseError_En(result.Code())
                  << " Invalid JSON: '" << command << "'" << std::endl;
        return false;
    }
    if (doc.IsObject() == false) {
        // JSON can contain only a value (e.g. "abc").
        // We require object as a JSON content (Strata JSON commands starts with '{' and ends with '}')
        std::cerr << "Content of JSON is not an object: '" << command << "'." << std::endl;
        // TODO: use logger from CS-440
        return false;
    }
    return true;
}
