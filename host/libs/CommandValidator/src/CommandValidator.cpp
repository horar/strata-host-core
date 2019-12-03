#include "CommandValidator.h"
#include <iostream>

// define the schemas

// this support platform id v1 and v2 
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
                                    "type": "integer"
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
                        "type": "object",
                        "properties": {
                        "version": {
                            "type": "string"
                        },
                        "build-date": {
                            "type": "string"
                        },
                        "checksum": {
                        }
                        },
                        "required": [
                        "version",
                        "build-date",
                        "checksum"
                        ]
                    },
                    "application": {
                        "type": "object",
                        "properties": {
                        "version": {
                            "type": "string"
                        },
                        "build-date": {
                            "type": "string"
                        },
                        "checksum": {
                        }
                        },
                        "required": [
                        "version",
                        "build-date",
                        "checksum"
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

CommandValidator::CommandValidator(/* args */)
{
}

CommandValidator::~CommandValidator()
{
}

rapidjson::SchemaDocument CommandValidator::parseSchema(const std::string &schema) {
    rapidjson::Document doc;
    
    // Parse the schema and check if it has valid json syntax
    if(doc.Parse(schema.c_str()).HasParseError()) {
        // Log error message 
    }

    // create the schema validator
    rapidjson::SchemaDocument schemaDoc(doc);
    return schemaDoc;
}

bool CommandValidator::validateCommandWithSchema(const std::string &command, const std::string &schema, rapidjson::Document &doc)   {  
    // Parse the schema and check if it has valid json syntax
    if(doc.Parse(schema.c_str()).HasParseError()) {
        return false;
    }

    // create the schema validator
    rapidjson::SchemaDocument schemaDoc(doc);
    rapidjson::SchemaValidator validator(schemaDoc);

    // parse the command and check it has valid json syntax
    if(doc.Parse(command.c_str()).HasParseError())  {
        return false;
    }

    // validate the command against the schema
    if(doc.Accept(validator)) {
        return true;
    }
    else{
        return false;
    }
}

bool CommandValidator::validateCommandWithSchema(const std::string &command, const rapidjson::SchemaDocument &schema, rapidjson::Document &doc)   {  
    rapidjson::SchemaValidator validator(schema);

    // parse the command and check it has valid json syntax
    if(doc.Parse(command.c_str()).HasParseError())  {
        return false;
    }

    // validate the command against the schema
    if(doc.Accept(validator)) {
        return true;
    }
    else{
        return false;
    }
}

bool CommandValidator::isValidRequestPlatorfmIdResponse(const std::string &command, rapidjson::Document &doc)    {
    return validateCommandWithSchema(command, CommandValidator::requestPlatformIdResSchema, doc);
}

bool CommandValidator::isValidAck(const std::string &command, rapidjson::Document &doc)   {
    return validateCommandWithSchema(command, CommandValidator::ackSchema, doc);
}

bool CommandValidator::isValidNotification(const std::string &command, rapidjson::Document &doc)   {
    return validateCommandWithSchema(command, CommandValidator::notificationSchema, doc);
}

bool CommandValidator::isValidSetPlatformId(const std::string &command, rapidjson::Document &doc) {
    return validateCommandWithSchema(command, CommandValidator::setPlatformIdResSchema, doc);
}

bool CommandValidator::isValidGetFWInfo(const std::string &command, rapidjson::Document &doc) {
    return validateCommandWithSchema(command, CommandValidator::getFWInfoResSchema, doc);
}

bool CommandValidator::isValidUpdateFW(const std::string &command, rapidjson::Document &doc)   {
    return validateCommandWithSchema(command, CommandValidator::updateFWResSchema, doc);
}

bool CommandValidator::isValidFlashFW(const std::string &command, rapidjson::Document &doc)   {
    return validateCommandWithSchema(command, CommandValidator::flashFWResSchema, doc);
}

bool CommandValidator::isValidJson(const std::string &command, rapidjson::Document &doc)  {
    // parse the command and make sure we have a valid JSON
    if(doc.Parse(command.c_str()).HasParseError())  {
        return false;
    }
    else   {
        return true;
    }
}
