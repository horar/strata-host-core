#include "CommandValidator.h"

#include <iostream>
#include <rapidjson/writer.h>
#include <rapidjson/error/en.h>

// define the schemas

// this support platform id v1 and v2
// [Mohammed] "count" can be string or integer. This change was implemented because of 
//              some released boards have it as a string instead of an integer.
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
                    "pattern":"^platform_id$"
                    },
                    "payload": {
                        "oneOf":[
                            {
                                "type": "object",
                                "properties": {
                                    "name": {
                                    "type": "string"
                                    },
                                    "platform_id": {
                                    "type": "string"
                                    },
                                    "class_id": {
                                    "type": "string"
                                    },
                                    "count": {
                                    "type": ["string", "integer"]
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
                            },
                            {
                                "type": "object",
                                "properties": {
                                    "verbose_name": {
                                    "type": "string"
                                    },
                                    "verbose_name_error": {
                                    "type": "string"
                                    },
                                    "platform_id_error": {
                                    "type": "string"
                                    },
                                    "platform_id": {
                                    "type": "string"
                                    }
                                },
                                "required": [
                                    "verbose_name",
                                    "platform_id"
                                ]
                            }
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

const rapidjson::SchemaDocument CommandValidator::updateFWResSchema(
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
                    "pattern": "^update_firmware$"
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

const rapidjson::SchemaDocument CommandValidator::flashFWResSchema(
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

const rapidjson::SchemaDocument CommandValidator::getFWInfoResSchema(
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
    {JsonType::getFwInfoRes, getFWInfoResSchema},
    {JsonType::flashFwRes, flashFWResSchema},
    {JsonType::updateFwRes, updateFWResSchema},
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
    if (parseJson(command, doc) == false) {
        return false;
    }

    return validate(type, doc);
}

bool CommandValidator::validate(const std::string &command, const std::string& schema, rapidjson::Document &doc) {
    if (parseJson(command, doc) == false) {
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
      std::cerr << "Unknown schema." << std::endl;
      return false;
  }

  return validateDocWithSchema(it->second, doc);
}

bool CommandValidator::isValidJson(const std::string &command) {
    return (rapidjson::Document().Parse(command.c_str()).HasParseError() == false);
}

bool CommandValidator::parseJson(const std::string &command, rapidjson::Document &doc) {
    rapidjson::ParseResult result = doc.Parse(command.c_str());
    if (result.IsError()) {
        // TODO: use logger from CS-440
        std::cerr << "JSON parse error at offset " << result.Offset() << ": " << rapidjson::GetParseError_En(result.Code())
                  << " Invalid JSON: '" << command << "'" << std::endl;
        return false;
    }
    return true;
}
