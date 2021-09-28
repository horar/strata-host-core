/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "command-validator-test.h"

#include "CommandValidator.h"
#include <rapidjson/writer.h>

using strata::CommandValidator;

void CommandValidatorTest::printJsonDoc(rapidjson::Document &doc)    {
    // print the doc
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    doc.Accept(writer);
    std::cout << buffer.GetString() << std::endl;
}

void CommandValidatorTest::SetUp()
{
}

void CommandValidatorTest::TearDown()
{
}

TEST_F(CommandValidatorTest, updateFWResTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // Valid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"start_bootloader",
                "payload":{
                    "status":"ok"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::startBootloaderNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"start_bootloader",
                "payload":{
                    "status":"failed"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::startBootloaderNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"start_bootloader",
                "payload":{
                    "status":"invalid FIB state"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::startBootloaderNotif, doc));


    // Invalid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"update_firm",
                "payload":{
                    "status":"ok"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::startBootloaderNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"start_bootloader",
                "payload":{
                    "status": 56465
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::startBootloaderNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"start_bootloader",
                "payload":{
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::startBootloaderNotif, doc));
}

TEST_F(CommandValidatorTest, flashFWResTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // valid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"flash_firmware",
                "payload":{
                    "status":"ok"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::flashFirmwareNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"flash_firmware",
                "payload":{
                    "status":"some error"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::flashFirmwareNotif, doc));

    // Invalid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"flash_firmre",
                "payload":{
                    "status":"ok"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::flashFirmwareNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"flash_firmware",
                "payload":{
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::flashFirmwareNotif, doc));

        testCommand = R"(
        {
            "notification":{
                "value":"flash_firmware",
                "payload":{
                    "status": -1
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification( CommandValidator::JsonType::flashFirmwareNotif, doc));
}

TEST_F(CommandValidatorTest, getFWInfoResTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // Valid test commands
    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {
                        "version":"158.58.54",
                        "date":"2018-04-01",
                        "checksum": "dsfdsf"
                    },
                    "application": {
                        "version":"1.1.1",
                        "date":"2018-04-01",
                        "checksum": 232332
                    }
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::getFirmwareInfoNotif, doc));

    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {},
                    "application": {
                        "version":"1.1.1",
                        "date":"2018-04-01",
                        "checksum": 232332
                    }
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::getFirmwareInfoNotif, doc));

    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {
                        "version":"158.58.54",
                        "date":"2018-04-01",
                        "checksum": "dsfdsf"
                    },
                    "application": {}
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::getFirmwareInfoNotif, doc));

    // Invalid test commands
    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {
                        "version": 1.1.1,
                        "date":"2018-4-1",
                        "checksum": ""
                    },
                    "application": {
                        "version":"1.1.1",
                        "date":"2018-04-01",
                        "checksum": ""
                    }
                }
            }
        })";
    EXPECT_FALSE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));

    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {
                        "version":"a.a.a",
                        "date": 20180410,
                        "checksum": ""
                    },
                    "application": {
                        "version":"213",
                        "date":"2018-04-01",
                        "checksum": ""
                    }
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::getFirmwareInfoNotif, doc));

// This JSON is not valid, but schema does not covers this situation (empty application and bootloader).
/*
    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {},
                    "application": {}
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::getFirmwareInfoNotif, doc));
*/
}

TEST_F(CommandValidatorTest, setPlatformIdResTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // Valid testing commands
    testCommand = R"(
        {
            "notification":{
                "value":"set_platform_id",
                "payload":{
                    "status": "ok"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::setPlatformIdNotif, doc));

    // Invalid testing commands
    testCommand = R"(
        {
            "notification":{
                "value":"set_platform_id",
                "payload":{
                    "status": "Else"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::setPlatformIdNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"set_plat",
                "payload":{
                    "status": "ok"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::setPlatformIdNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"set_platform_id",
                "payload":{

                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::setPlatformIdNotif, doc));
}

TEST_F(CommandValidatorTest, notificationTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // Valid test commands
    testCommand = R"({"notification":{"value":"platform_id","payload":{"name":"Hello Strata","platform_id":"126","class_id":"226","count":0,"platform_id_version":"2.0"}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::notification, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{"volts":2.83,"bits":3220}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::notification, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::notification, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{"volts":2.83}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::notification, doc));

    testCommand = R"({"notification":{"payload":{"volts":2.83,"bits":3220}}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::notification, doc));

    testCommand = R"({"notification":{"value":"pot"}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::notification, doc));

    testCommand = R"({"value":"pot","payload":{"volts":2.83,"bits":3220}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::notification, doc));
}

TEST_F(CommandValidatorTest, ackTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // valid testing commands
    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":true,"return_string":"command valid"}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::ack, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":"true","return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::ack, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::ack, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::ack, doc));

    testCommand = R"({"ack":"request_platform_id"})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::ack, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":"true","return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::ack, doc));
}

TEST_F(CommandValidatorTest, sampleTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));
}

TEST_F(CommandValidatorTest, requestPlatorfmIdResponseTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // valid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":"1",
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":"1",
                    "platform_id_version":"2.0",
                    "verbose_name":"WaterHeater"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));

    // API v2
    // embedded
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"PlatformId API version 2.0",
                    "controller_type":1,
                    "platform_id":"00000000-0000-0000-0000-000000000000",
                    "class_id":"00000000-0000-0000-0000-000000000000",
                    "board_count":1
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));

    // assisted
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"PlatformId API version 2.0",
                    "controller_type":1,
                    "platform_id":"00000000-0000-0000-0000-000000000000",
                    "class_id":"00000000-0000-0000-0000-000000000000",
                    "board_count":1,
                    "controller_platform_id":"00000000-0000-0000-0000-000000000000",
                    "controller_class_id":"00000000-0000-0000-0000-000000000000",
                    "controller_board_count":1,
                    "fw_class_id":"00000000-0000-0000-0000-000000000000"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));

    // assisted without connected board
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"PlatformId API version 2.0",
                    "controller_type":1,
                    "controller_platform_id":"00000000-0000-0000-0000-000000000000",
                    "controller_class_id":"00000000-0000-0000-0000-000000000000",
                    "controller_board_count":1,
                    "fw_class_id":"00000000-0000-0000-0000-000000000000"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_TRUE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));

    // Invalid test command
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":101,
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count": 1.1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"PlatformId API version 2.0",
                    "controller_type":1,
                    "platform_id":"00000000-0000-0000-0000-000000000000",
                    "controller_class_id":"00000000-0000-0000-0000-000000000000",
                    "board_count":1
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));

    // Deprecated response
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                        "verbose_name":"ON WaterHeater",
                        "verbose_name_error":"error_data_corrupted",
                        "platform_id":"SEC.2018.0.0.0.0.00000000-0000-0000-0000-000000000000",
                        "platform_id_error":"not_flashed"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
    EXPECT_FALSE(CommandValidator::validateNotification(CommandValidator::JsonType::reqPlatformIdNotif, doc));
}

TEST_F(CommandValidatorTest, isValidJsonTest)
{
    std::string testCommand;
    QByteArray testJsonCommand;
    rapidjson::Document doc;

    // valid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    testJsonCommand = QByteArray::fromStdString(testCommand);
    EXPECT_TRUE(CommandValidator::isValidJson(testJsonCommand));
    EXPECT_TRUE(CommandValidator::parseJsonCommand(testJsonCommand, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{}
            }
        }
    )";
    testJsonCommand = QByteArray::fromStdString(testCommand);
    EXPECT_TRUE(CommandValidator::isValidJson(testJsonCommand));
    EXPECT_TRUE(CommandValidator::parseJsonCommand(testJsonCommand, doc));

    // Invalid test command
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"10a",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
        }
    )";
    testJsonCommand = QByteArray::fromStdString(testCommand);
    EXPECT_FALSE(CommandValidator::isValidJson(testJsonCommand));
    EXPECT_FALSE(CommandValidator::parseJsonCommand(testJsonCommand, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":101,
                    "class_id":"201",
                    "count":1,
                    "platform_id_version"
                }
            }
        }
    )";
    testJsonCommand = QByteArray::fromStdString(testCommand);
    EXPECT_FALSE(CommandValidator::isValidJson(testJsonCommand));
    EXPECT_FALSE(CommandValidator::parseJsonCommand(testJsonCommand, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0",
                }
            }
        }
    )";
    testJsonCommand = QByteArray::fromStdString(testCommand);
    EXPECT_FALSE(CommandValidator::isValidJson(testJsonCommand));
    EXPECT_FALSE(CommandValidator::parseJsonCommand(testJsonCommand, doc));
}

TEST_F(CommandValidatorTest, isValidCmdTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // valid test commands
    testCommand = R"({"cmd":"nl7sz58_write_io","payload":{"a":1, "b":0, "c":1}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::cmd, doc));

    testCommand = R"({"cmd":"nl7sz58_nand"})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::cmd, doc));

    // Invalid test commands
    testCommand = R"({"cmd":"nl7sz58_write_io","payload":["a", "b", "c"]})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::cmd, doc));

    testCommand = R"({"cmd":"nl7sz58_write_io","payload":"string"})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::cmd, doc));

    testCommand = R"("cmd":{"nl7sz58_nand":6})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::cmd, doc));
}

TEST_F(CommandValidatorTest, isValidStrataCommandTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // Valid test commands
    testCommand = R"({"notification": {"value":"get_firmware_info","payload": {"bootloader": {"version":"158.58.54","build-date":"2018-04-01","checksum": "dsfdsf"},"application": {"version":"1.1.1","build-date":"2018-04-01","checksum": 232332}}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({  "notification":{  "value":"platform_id","payload":{  "name":"WaterHeater","platform_id":"101","class_id":"201","count":1,"platform_id_version":"2.0"}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"platform_id","payload":{}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"platform_id","payload":{"name":"Hello Strata","platform_id":"126","class_id":"226","count":0,"platform_id_version":"2.0"}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{"volts":2.83,"bits":3220}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{"volts":2.83}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"flash_firmware","payload":{"status":"ok"}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"flash_firmware","payload":{"status":"some error"}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":true,"return_string":"command valid"}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"start_bootloader","payload":{"status":"ok"}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"start_bootloader","payload":{"status":"failed"}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"start_bootloader","payload":{"status":"invalid FIB state"}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({  "notification":{  "value":"platform_id","payload":{  "name":"WaterHeater","platform_id":"101","class_id":"201","count":1,"platform_id_version":"2.0"}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"platform_id","payload":{"verbose_name":"ON WaterHeater","verbose_name_error":"error_data_corrupted","platform_id":"SEC.2018.0.0.0.0.00000000-0000-0000-0000-000000000000","platform_id_error":"not_flashed"}}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"cmd":"nl7sz58_write_io","payload":{"a":1, "b":0, "c":1}})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"cmd":"nl7sz58_nand"})";
    EXPECT_TRUE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    // Invalid test commands
    testCommand = R"({"cmd":"nl7sz58_write_io","payload":["a", "b", "c"]})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"cmd":"nl7sz58_write_io","payload":"string"})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"("cmd":{"nl7sz58_nand":6})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification": {"value":"get_firmware_info","payload": {"bootloader": {"version": 1.1.1,"build-date":"2018-4-1","checksum": ""},"application": {"version":"1.1.1","build-date":"2018-04-01","checksum": ""}}}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({  "notification":{  "value":"platform_id","payload":{  "name":"WaterHeater","platform_id":"10a","class_id":"201","count":1,"platform_id_version":"2.0"}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"platform_id","payload":{"name":"WaterHeater","platform_id":101,"class_id":"201","count":1,"platform_id_version"}}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"platform","payload":{"name":"WaterHeater","platform_id":"101","class_id":"201","count":1,"platform_id_version":"2.0",}}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({  "notification":{  "value":"platform_id","payload":{  "name":"WaterHeater","platform_id":101,"class_id":"201","count":1,"platform_id_version":"2.0"}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"payload":{"volts":2.83,"bits":3220}}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"notification":{"value":"pot"}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"value":"pot","payload":{"volts":2.83,"bits":3220}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":"true","return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"ack":"request_platform_id"})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":"true","return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(QByteArray::fromStdString(testCommand), CommandValidator::JsonType::strataCommand, doc));
}

TEST_F(CommandValidatorTest, containsObject)
{
    std::string testCommand;
    rapidjson::Document doc;

    testCommand = R"({"cmd":"test"})";
    EXPECT_TRUE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));

    testCommand = R"("test")";
    EXPECT_FALSE(CommandValidator::parseJsonCommand(QByteArray::fromStdString(testCommand), doc));
}
